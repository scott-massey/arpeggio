//
//  FollowersSearchViewController.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/16/21.
//

import UIKit

class FollowersSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var allUsers: [FirebaseUserDetails] = []
    var following: [FirebaseUserDetails] = []
    var notFollowing: [FirebaseUserDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView()
        getAllUsers()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func getAllUsers() {
        Spotify.shared.databaseRef
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
                }
                self.notFollowing = self.allUsers.filter { user in
                    return !self.following.contains(user) && user.FBUID != Spotify.shared.currentFBUser?.uid
                }
                
                self.tableView.reloadData()
            }) { error in
                print(error.localizedDescription)
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notFollowing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FollowingAddTableViewCell
        
        let userDetails = notFollowing[indexPath.row]
        
        if let unwrappedCell = cell {
            unwrappedCell.displayName.text = userDetails.displayName
            unwrappedCell.spotifyUserURI = userDetails.spotifyUserURI
            unwrappedCell.FBUID = userDetails.FBUID
            
            let imageURL = URL(string: userDetails.imageURL)
            
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seeProfile") {
            guard let selectedIndex = tableView.indexPathsForSelectedRows?.last else {
                return
            }
            
            let selectedUser = notFollowing[selectedIndex.row]
            let navVC = segue.destination as? UINavigationController
            let profileVC = navVC?.viewControllers.first as? ProfileController
            profileVC?.selectedUser = selectedUser
            profileVC?.viewType = .addFollowing
        }
    }
}
