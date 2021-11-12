//
//  SceneDelegate.swift
//  arpeggio
//
//  Created by Scott Massey on 11/7/21.
//

import UIKit
import SpotifyWebAPI
import KeychainAccess

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if (Spotify.shared.keychain[data: Spotify.shared.authorizationManagerKey] != nil)  {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let home = storyboard.instantiateViewController(identifier: "Home")
            window?.rootViewController = home
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            // **Always** validate URLs; they offer a potential attack vector into
            // your app.
            guard url.scheme == Spotify.shared.loginCallbackURL.scheme else {
                print("not handling URL: unexpected scheme: '\(url)'")
                return
            }
            
            print("received redirect from Spotify: '\(url)'")
            
            Spotify.shared.isRetrievingTokens = true
            Spotify.shared.api.authorizationManager.requestAccessAndRefreshTokens(
                redirectURIWithQuery: url,
                codeVerifier: Spotify.shared.codeVerifier,
                state: Spotify.shared.authorizationState
            )
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                Spotify.shared.isRetrievingTokens = false
                if case .failure(let error) = completion {
                    print("couldn't retrieve access and refresh tokens:\n\(error)")
                    let alertTitle: String
                    let alertMessage: String
                    if let authError = error as? SpotifyAuthorizationError,
                       authError.accessWasDenied {
                        alertTitle = "You Denied The Authorization Request :("
                        alertMessage = ""
                    }
                    else {
                        alertTitle =
                            "Couldn't Authorization With Your Account"
                        alertMessage = error.localizedDescription
                    }
                    print("Error \(alertTitle): \(alertMessage)")
                }
                Spotify.shared.authorizationState = String.randomURLSafe(length: 128)
                Spotify.shared.codeVerifier = String.randomURLSafe(length: 128)
                Spotify.shared.codeChallenge = String.makeCodeChallenge(codeVerifier: Spotify.shared.codeVerifier)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let home = storyboard.instantiateViewController(identifier: "Home")
                self.window?.rootViewController = home
            })
            .store(in: &Spotify.shared.cancellables)
        }
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        
        // change the root view controller to your specific view controller
        window.rootViewController = vc
        
        // add animation
        UIView.transition(with: window,
                          duration: 0.5,
                          options: [.transitionFlipFromLeft],
                          animations: nil,
                          completion: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

