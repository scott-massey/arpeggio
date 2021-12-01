//
//  FollowersViewController.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/11/21.
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
        if (Spotify.shared.followingInfoCallbacks["followers"] == nil) {
            Spotify.shared.followingInfoCallbacks["followers"] = self.refreshFollowing
            refreshFollowing(following: Spotify.shared.followingInfo)
        }
    }
    
    func refreshFollowing (following: [FirebaseUserDetails]) {
        followingInfo = Spotify.shared.followingInfo
        self.tableView.reloadData()
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
