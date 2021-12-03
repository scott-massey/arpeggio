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
        
        followingInfo = Spotify.shared.followingInfo
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        tableView.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FollowingDisplayTableViewCell
        else { return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) }
        
        let userInfo = followingInfo[indexPath.row]
        
        cell.followingName.text = userInfo.displayName
        cell.spotifyUserURI = userInfo.spotifyUserURI
        cell.FBUID = userInfo.FBUID
            
        do {
            if let imageURL = URL(string: userInfo.imageURL) {
                let data = try Data(contentsOf: imageURL)
                if let image = UIImage(data: data) {
                    let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 50.0, height: 50.0))
                    cell.profileImageView.image = resizedImage
                }
            }
        } catch {
            print("Error: could not show image")
        }

        return cell
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
