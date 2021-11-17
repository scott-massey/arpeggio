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
    
    var data: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView()
        updateData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateData()
    }
    
    func updateData() {
        data = Followers.shared.uidList
        print(data)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FollowingDisplayTableViewCell
        
        let userUID = data[indexPath.row]
        print(userUID)
        let userDetails = Followers.shared.getUserDetails(userUID: userUID)
        
        //print(userDetails)
        
        if let unwrappedCell = cell {
            unwrappedCell.followingName.text = userDetails.displayName
            unwrappedCell.spotifyUserURI = userDetails.spotifyUserURI
            
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
