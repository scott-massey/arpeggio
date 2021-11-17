//
//  FollowersSearchViewController.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/11/21.
//

import UIKit

class FollowersSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var allUsers: [FirebaseUserDetails] = []
    
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
            .observeSingleEvent(of: .value, with: { snapshot in
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
                self.tableView.reloadData()
            }) { error in
                print(error.localizedDescription)
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FollowingAddTableViewCell
        
        let userDetails = allUsers[indexPath.row]
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
