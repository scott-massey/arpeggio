//
//  SceneDelegate.swift
//  arpeggio
//
//  Created by Scott Massey on 11/7/21.
//

import UIKit
import SpotifyWebAPI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("openURLContexts")
        if let url = URLContexts.first?.url {
            // Handle URL
            print(url)
            
            if let view = self.window {
                if let vc = view.rootViewController as? ViewController {
                    // **Always** validate URLs; they offer a potential attack vector into
                    // your app.
                    guard url.scheme == vc.spotify.loginCallbackURL.scheme else {
                        print("not handling URL: unexpected scheme: '\(url)'")
                        return
                    }
                    
                    print("received redirect from Spotify: '\(url)'")
                    
                    // This property is used to display an activity indicator in `LoginView`
                    // indicating that the access and refresh tokens are being retrieved.
                    vc.spotify.isRetrievingTokens = true
                    
                    // Complete the authorization process by requesting the access and
                    // refresh tokens.
                    vc.spotify.api.authorizationManager.requestAccessAndRefreshTokens(
                        redirectURIWithQuery: url,
                        codeVerifier: vc.spotify.codeVerifier,
                        // This value must be the same as the one used to create the
                        // authorization URL. Otherwise, an error will be thrown.
                        state: vc.spotify.authorizationState
                    )
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        // Whether the request succeeded or not, we need to remove the
                        // activity indicator.
                        vc.spotify.isRetrievingTokens = false
                        
                        /*
                         After the access and refresh tokens are retrieved,
                         `SpotifyAPI.authorizationManagerDidChange` will emit a signal,
                         causing `Spotify.authorizationManagerDidChange()` to be called,
                         which will dismiss the loginView if the app was successfully
                         authorized by setting the @Published `Spotify.isAuthorized`
                         property to `true`.

                         The only thing we need to do here is handle the error and show it
                         to the user if one was received.
                         */
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
                    })
                    .store(in: &vc.spotify.cancellables)
                    
                    // MARK: IMPORTANT: generate a new value for the state parameter after
                    // MARK: each authorization request. This ensures an incoming redirect
                    // MARK: from Spotify was the result of a request made by this app, and
                    // MARK: and not an attacker.
                    vc.spotify.authorizationState = String.randomURLSafe(length: 128)
                }
            }
        }
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

