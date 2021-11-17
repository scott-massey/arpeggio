//
//  Followers.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/10/21.
//

import Foundation

final class Followers {
    static let shared = Followers()
    
    var currentFollowingDictionary: [String:String] = [:]
    var uidList: [String] = []
    private var tmp: FirebaseUserDetails = FirebaseUserDetails(displayName: "", imageURL: "", spotifyUserURI: "", FBUID: "")
    
    init() {
        getCurrentFollowings()
    }
    
    func getCurrentFollowings() {
        guard let fbUser = Spotify.shared.currentFBUser else { return }
        
        Spotify.shared.databaseRef
            .child("users")
            .child(fbUser.uid)
            .observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary

                if let unwrappedDictionary = value {
                    self.currentFollowingDictionary = unwrappedDictionary["following"] as? [String:String] ?? [:]
                    self.uidList = Array(self.currentFollowingDictionary.keys)
                }
                
            }) { error in
                print(error.localizedDescription)
            }
    }
    
    func updateCurrentFollowings(FBUID: String) {
        guard let fbUser = Spotify.shared.currentFBUser else { return }
        currentFollowingDictionary[FBUID] = "FOLLOWING"
        
        let childValues = ["users/\(fbUser.uid)/following": currentFollowingDictionary]
        
        Spotify.shared.databaseRef.updateChildValues(childValues)
    }
    
    func getUserDetails(userUID: String) -> FirebaseUserDetails {
        Spotify.shared.databaseRef
            .child("users")
            .child(userUID)
            .observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let displayName = value?["displayName"] as? String ?? ""
                let profileURL = value?["profileURL"] as? String ?? ""
                let spotifyUserURI = value?["spotifyUserURI"] as? String ?? ""
                self.tmp = FirebaseUserDetails(
                    displayName: displayName,
                    imageURL: profileURL,
                    spotifyUserURI: spotifyUserURI,
                    FBUID: userUID
                )
            }) { error in
                print(error.localizedDescription)
            }
        return tmp
    }
}
