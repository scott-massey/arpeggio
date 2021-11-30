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
                    self.fetchFollowers()
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
        
        self.fetchFollowers()
    }
    
    func follow(followingId: String) {
        if (followingId == "") { return }
        guard let fbUser = Spotify.shared.currentFBUser else { return }
        
        let childValues = ["users/\(fbUser.uid)/following/\(followingId)": "FOLLOWING"]
        
        self.databaseRef.updateChildValues(childValues)
    }
    
    func unFollow(userId: String) {
        if (userId == "") { return }
        guard let fbUser = Spotify.shared.currentFBUser else { return }
        
        let child = "users/\(fbUser.uid)/following/\(userId)"
        
        self.databaseRef.child(child).removeValue()
    }
    
    func fetchAllUsers() {
        self.databaseRef
            .child("users")
            .observe(.value, with: { snapshot in
                self.allUsers = []
                
                let value = snapshot.value as? NSDictionary
                
                if let allUserResponse = value {
                    for (uid , user) in allUserResponse {
                        
                        let userNSDictionary = user as? NSDictionary
                        
                        let displayName = userNSDictionary?["displayName"] as? String ?? ""
                        let profileURL = userNSDictionary?["profileURL"] as? String ?? ""
                        let spotifyUserURI = userNSDictionary?["spotifyUserURI"] as? String ?? ""
                        let stringUID = uid as? String ?? ""
                        
                        self.allUsers.append(
                            FirebaseUserDetails(
                                displayName: displayName,
                                imageURL: profileURL,
                                spotifyUserURI:spotifyUserURI,
                                FBUID: stringUID
                            )
                        )
                    }
                    
                    for (_, callback) in self.allUsersCallbacks {
                        callback(self.allUsers)
                    }
                }
                

                
            }) { error in
                print(error.localizedDescription)
            }
    }
    
    func fetchFollowers() {
        guard let fbUser = Spotify.shared.currentFBUser else { return }
        
        Spotify.shared.databaseRef
            .child("users")
            .child(fbUser.uid)
            .observe(.value, with: { snapshot in
                self.followingInfo = []
                
                let value = snapshot.value as? NSDictionary

                if let unwrappedDictionary = value {
                    let currentFollowingDictionary:[String:String] = unwrappedDictionary["following"] as? [String:String] ?? [:]
                    let data = Array(currentFollowingDictionary.keys)
                    
                    
                    for uid in data {
                        Spotify.shared.databaseRef
                            .child("users")
                            .child(uid)
                            .observeSingleEvent(of: .value, with: { snapshot in
                                let result = snapshot.value as? NSDictionary
                                
                                if let unwrappedDict = result {
                                    let displayName = unwrappedDict["displayName"] as? String ?? ""
                                    let profileURL = unwrappedDict["profileURL"] as? String ?? ""
                                    let spotifyUserURI = unwrappedDict["spotifyUserURI"] as? String ?? ""
                                    
                                    self.followingInfo.append(FirebaseUserDetails(displayName: displayName, imageURL: profileURL, spotifyUserURI: spotifyUserURI, FBUID: uid))
                                    
                                }
                            }) {error in
                                print(error.localizedDescription)
                            }
                    }
                }
                
            }) { error in
                print(error.localizedDescription)
            }
    }
    
}
