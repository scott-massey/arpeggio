//
//  Firebase.swift
//  arpeggio
//
//  Created by Scott Massey on 11/13/21.
//
import Firebase
import FirebaseDatabase
import SpotifyWebAPI


extension Spotify {   
    func firebaseAuth(spotifyUser: SpotifyUser) {
        let email = spotifyUser.email!
        let password = spotifyUser.id.hashed(.sha256)!
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let fbUser = authResult?.user, error == nil {
                self.currentFBUser = fbUser
                self.createFirebaseDBUser()
            } else if AuthErrorCode(rawValue: error!._code) == .emailAlreadyInUse {
                // Email already exists. Sign the user in.
                Auth.auth().signIn(withEmail: email, password: password) {
                    authResult, error in
                    
                    guard let fbUser = authResult?.user, error == nil else {
                        return
                    }
                    self.currentFBUser = fbUser
                }
            }
        }
    }
    
    func createFirebaseDBUser() {
        guard let spotifyUser = self.currentUser else { return }
        guard let fbUser = self.currentFBUser else { return }
        let profileImage = spotifyUser.images?[0]
        let url = profileImage?.url.absoluteString
        let spotifyUserURI = spotifyUser.uri
        
        self.databaseRef
            .child("users")
            .child(fbUser.uid)
            .setValue([
                "email": spotifyUser.email!,
                "displayName": spotifyUser.displayName!,
                "profileURL": url!,
                "spotifyUserURI": spotifyUserURI
            ])
    }
}
