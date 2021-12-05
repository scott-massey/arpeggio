//
//  FollowersSearchViewController.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/11/21.
//

import UIKit

class FollowersSearchViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var following: [FirebaseUserDetails] = []
    var notFollowing: [FirebaseUserDetails] = []
    
    var tableData: [FirebaseUserDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView()
        setupSearchBar()

        refreshFollowing(allUsers: Spotify.shared.allUsers)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        following = Spotify.shared.followingInfo
        refreshFollowing(allUsers: Spotify.shared.allUsers)
        tableView.reloadData()
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func refreshFollowing(allUsers: [FirebaseUserDetails]) {
        self.notFollowing = allUsers.filter { user in
            return !self.following.contains(user) && user.FBUID != Spotify.shared.currentFBUser?.uid
        }
        
        self.tableData = self.notFollowing
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            self.tableData = self.notFollowing
            self.tableView.reloadData()
            return
        }
        
        self.tableData = notFollowing.filter { user in
            return user.FBUID != Spotify.shared.currentFBUser?.uid && user.displayName.contains(text)
        }
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FollowingAddTableViewCell
        
        let userDetails = tableData[indexPath.row]
        
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
                if let image = UIImage(named: "imageNotFound") {
                    let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 50.0, height: 50.0))
                    unwrappedCell.profileImageView.image = resizedImage
                }
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
            
            let selectedUser = tableData[selectedIndex.row]
            let profileVC = segue.destination as? ProfileController
            profileVC?.selectedUser = selectedUser
            profileVC?.viewType = .addFollowing
        }
    }
    
    // copied from https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let size = image.size
       
       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height
       
       // Figure out what our orientation is, and use that to form the rectangle
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }
       
       // This is the rect that we've calculated out and this is what is actually used below
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
       
       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       return newImage!
    }
    //end of copy
}
