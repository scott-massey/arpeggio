//
//  Firebase.swift
//  arpeggio
//
//  Created by Scott Massey on 11/13/21.
//
import Firebase


extension Spotify {   
    func firebaseAuth(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let fbUser = authResult?.user, error == nil {
                self.currentFBUser = fbUser
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
}
