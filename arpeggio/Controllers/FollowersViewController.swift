//
//  FollowersViewController.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/16/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class FollowersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var followingInfo: [FirebaseUserDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        trackFollowers()
    }
    
    func trackFollowers() {
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
                                    
                                    print("New following info: \(self.followingInfo)")
                                    
                                    self.tableView.reloadData()
                                    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FollowingDisplayTableViewCell
        let userInfo = followingInfo[indexPath.row]
        
        if let unwrappedCell = cell {
            unwrappedCell.followingName.text = userInfo.displayName
            unwrappedCell.spotifyUserURI = userInfo.spotifyUserURI
            unwrappedCell.FBUID = userInfo.FBUID
            
            let imageURL = URL(string: userInfo.imageURL)
            
            do {
                if let unwrappedImageURL = imageURL {
                    let data = try Data(contentsOf: unwrappedImageURL)
                    let image = UIImage(data: data)
                    unwrappedCell.profileImageView.image = image
                }
            } catch {
                print("Error: could not show image")
            }
            
            return unwrappedCell
        }
                
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addFollowing") {
            let followersSearchVC = segue.destination as? FollowersSearchViewController
            followersSearchVC?.following = followingInfo
        } else if (segue.identifier == "seeProfile") {
            guard let selectedIndex = tableView.indexPathsForSelectedRows?.last else {
                return
            }
            
            let selectedUser = followingInfo[selectedIndex.row]
            let navVC = segue.destination as? UINavigationController
            let profileVC = navVC?.viewControllers.first as? ProfileController
            profileVC?.selectedUser = selectedUser
            profileVC?.viewType = .following
        }
        
    }


}
