//
//  FeedViewController.swift
//  arpeggio
//
//  Created by Justin Pressman on 11/11/21.
//

import UIKit
import Combine
import KeychainAccess
import SpotifyWebAPI
import Firebase
import FirebaseDatabase

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post] = []
    var filteredPosts: [Post] = []
    var followingInfo: [String: FirebaseUserDetails] = [:]
    var cachedImages: [String: UIImage] = [:]
    
    func setFollowingInfo(following: [FirebaseUserDetails]) {
        tableView.isHidden = true
        for user in following {
            followingInfo[user.FBUID] = user
        }
        cacheImages()
        filteredPosts = posts.filter { post in return followingInfo.keys.contains(post.userId) }
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func cacheImages() {
        for (uid, user) in followingInfo {
            if (cachedImages[uid] == nil) {
                // Get Poster's Image URL
                let imageURL = URL(string: user.imageURL)
                do {
                    if let unwrappedImageURL = imageURL {
                        let data = try Data(contentsOf: unwrappedImageURL)
                        let image = UIImage(data: data)
                        cachedImages[uid] = image
                    }
                } catch {
                    print("Error: could not show image")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell ?? FeedCell(style: .default, reuseIdentifier: "FeedCell")
        
        let post = filteredPosts[indexPath.row]
        let poster = followingInfo[post.userId]
                
        myCell.message.text = post.message
        myCell.poster = poster ?? FirebaseUserDetails(displayName: "Test Name", imageURL: "test url", spotifyUserURI: "test uri", FBUID: "test id")
        myCell.avatarImage.image = cachedImages[post.userId] ?? cachedImages["default"]
        myCell.avatarImage.layer.masksToBounds = true
        myCell.avatarImage.layer.cornerRadius = 25
        myCell.avatarImage.clipsToBounds = true
        
        return myCell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cachedImages["default"] = UIImage(systemName: "person.circle")
        
        setupTableView()
        //Sets the navigation title with text and image
        self.navigationItem.titleView = navTitleWithImageAndText(imageName: "Logo")
        getData()
        
        if (Spotify.shared.followingInfoCallbacks["feed"] == nil) {
            Spotify.shared.followingInfoCallbacks["feed"] = setFollowingInfo
            setFollowingInfo(following: Spotify.shared.followingInfo)
        }
    }
            

    func navTitleWithImageAndText(imageName: String) -> UIView {
        let titleView = UIView()

        // Creates the image view
        let image = UIImageView()
        image.image = UIImage(named: imageName)
        image.frame = CGRect(x: -40, y: -10, width: 80, height: 21)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        titleView.addSubview(image)
        titleView.sizeToFit()
        return titleView
    }
    
    func getData() {
        Spotify.shared.databaseRef.child("posts").observe(DataEventType.value, with: { snapshot in
            if let posts = snapshot.value as? NSDictionary {
                self.posts = []
                
                for (_, post) in posts {
                    let postDict = post as? NSDictionary
                    
                    let message = postDict?["message"] as? String ?? ""
                    let url = postDict?["url"] as? String ?? ""
                    let userId = postDict?["userId"] as? String ?? ""
                    
                    self.posts.append(Post(message: message, url: url, userId: userId))
                }
                self.tableView.reloadData()
            }
        })
    }

    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "JustinCell")
        tableView.dataSource = self
        tableView.delegate = self
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
