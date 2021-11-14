//
//  Spotify.swift
//  arpeggio
//
//  Created by Scott Massey on 11/10/21.
//

import UIKit
import Combine
import SpotifyWebAPI
import KeychainAccess
import Firebase
import FirebaseDatabase

final class Spotify {
    static let shared = Spotify()
    
    private static let clientId: String = {
        if let clientId = ProcessInfo.processInfo
                .environment["CLIENT_ID"] {
            return clientId
        }
        fatalError("Could not find 'CLIENT_ID' in environment variables")
    }()
    
    let authorizationManagerKey = "authorizationManager"
    let loginCallbackURL = URL(
        string: "arpeggio://login-callback"
    )!
    
    var authorizationState = String.randomURLSafe(length: 128)
    var codeVerifier = String.randomURLSafe(length: 128)
    var codeChallenge = ""
    
    var currentUser: SpotifyUser? = nil
    var isAuthorized = false
    var isRetrievingTokens = false
    
    let keychain = Keychain(service: "com.washu.arpeggio")
    
    let api = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: clientId
        )
    )
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: Firebase stuff
    var currentFBUser: User? = nil
    var databaseRef = Database.database().reference()
    
    init() {
        // Configure the loggers.
        self.api.apiRequestLogger.logLevel = .trace
        
        self.codeChallenge = String.makeCodeChallenge(codeVerifier: self.codeVerifier)
        
        self.api.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
        
        self.api.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)
        
        if let authManagerData = keychain[data: self.authorizationManagerKey] {
            
            do {
                // Try to decode the data.
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowPKCEManager.self,
                    from: authManagerData
                )
                print("found authorization information in keychain")
                self.api.authorizationManager = authorizationManager
                
            } catch {
                print("could not decode authorizationManager from data:\n\(error)")
            }
        }
        else {
            print("did NOT find authorization information in keychain")
        }
    }
    
    func authorize() {
        let url = api.authorizationManager.makeAuthorizationURL(
            redirectURI: self.loginCallbackURL,
            codeChallenge: self.codeChallenge,
            state: authorizationState,
            scopes: [
                .ugcImageUpload,
                .userReadPlaybackState,
                .userModifyPlaybackState,
                .userReadCurrentlyPlaying,
                .userReadRecentlyPlayed,
                .streaming,
                .appRemoteControl,
                .playlistReadPrivate,
                .playlistModifyPublic,
                .playlistModifyPrivate,
                .playlistReadCollaborative,
                .userLibraryRead,
                .userLibraryModify,
                .userTopRead,
                .userReadEmail,
                .userReadPrivate
            ]
        )!
        UIApplication.shared.open(url)
        
    }
    
    func authorizationManagerDidChange() {
        self.isAuthorized = self.api.authorizationManager.isAuthorized()
        
        print(
            "Spotify.authorizationManagerDidChange: isAuthorized:",
            self.isAuthorized
        )
        
        self.retrieveCurrentUser()
        
        do {
            // Encode the authorization information to data.
            let authManagerData = try JSONEncoder().encode(
                self.api.authorizationManager
            )
            
            // Save the data to the keychain.
            keychain[data: self.authorizationManagerKey] = authManagerData
            print("did save authorization manager to keychain")
            
        } catch {
            print(
                "couldn't encode authorizationManager for storage " +
                    "in keychain:\n\(error)"
            )
        }
        
    }
    
    func authorizationManagerDidDeauthorize() {
        self.currentUser = nil
        
        do {
            try keychain.remove(self.authorizationManagerKey)
            print("did remove authorization manager from keychain")
            
        } catch {
            print(
                "couldn't remove authorization manager " +
                "from keychain: \(error)"
            )
        }
    }

    
    func retrieveCurrentUser(onlyIfNil: Bool = true) {
        
        if onlyIfNil && self.currentUser != nil {
            return
        }

        guard self.isAuthorized else { return }

        self.api.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("couldn't retrieve current user: \(error)")
                    }
                },
                receiveValue: { user in
                    self.currentUser = user
                    if (onlyIfNil) {
                        self.firebaseAuth(spotifyUser: user)
                    }
                }
            )
            .store(in: &cancellables)
    }
}
