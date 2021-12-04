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
    var tracks: [String: Track] = [:]
    
    func setFollowingInfo(following: [FirebaseUserDetails]) {
        let currentFBUser = Spotify.shared.currentFBUser
        let currentSpotifyUser = Spotify.shared.currentUser
        let currentUser = FirebaseUserDetails(displayName: currentSpotifyUser?.displayName ?? "", imageURL: currentSpotifyUser?.images?[0].url.absoluteString ?? "", spotifyUserURI: currentSpotifyUser?.uri ?? "", FBUID: currentFBUser?.uid ?? "")
        for user in following {
            followingInfo[user.FBUID] = user
        }
        followingInfo[currentUser.FBUID] = currentUser
        cacheUserImages()
        self.tableView.reloadData()
    }
    
    func cacheUserImages() {
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
                    print("Error: could not cache profile image \(uid)")
                }
            }
        }
    }
    
    func cacheTrackImages() {
        for (_, track) in tracks {
            let imageURL = track.album?.images?[0].url
            do {
                guard let unwrappedImageURL = imageURL else { continue }
                let data = try Data(contentsOf: unwrappedImageURL)
                let image = UIImage(data: data)
                cachedImages[track.id ?? ""] = image
            } catch {
                print("Error: could not cache track image \(track.id ?? "unknown")")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        filteredPosts = posts.filter { post in return followingInfo.keys.contains(post.userId) }
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        filteredPosts = posts.filter { post in return followingInfo.keys.contains(post.userId) }
        let myCell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell ?? FeedCell(style: .default, reuseIdentifier: "FeedCell")
        
        let post = filteredPosts[indexPath.section]
        let poster = followingInfo[post.userId]
        let track = tracks[post.url]
        let trackImage = cachedImages[track?.id ?? "default"]
                
        myCell.trackId = track?.id
        myCell.artistAlbum.text = "\(track?.artists?.splitByComma() ?? "uknown") | \(track?.album?.name ?? "unknown")"
        myCell.message.text = post.message
        myCell.poster = poster ?? FirebaseUserDetails(displayName: "Test Name", imageURL: "test url", spotifyUserURI: "test uri", FBUID: "test id")
        myCell.albumArt.image = trackImage
        myCell.avatarImage.image = cachedImages[post.userId] ?? cachedImages["default"]
        myCell.avatarImage.layer.masksToBounds = true
        myCell.avatarImage.layer.cornerRadius = 25
        myCell.avatarImage.clipsToBounds = true
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
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
                var trackUrls: [SpotifyURIConvertible] = []
                
                for (_, post) in posts {
                    let postDict = post as? NSDictionary
                    
                    let message = postDict?["message"] as? String ?? ""
                    let url = postDict?["url"] as? String ?? ""
                    let userId = postDict?["userId"] as? String ?? ""
                    let timestamp = postDict?["timestamp"] as? Double ?? 0
                    
                    self.posts.append(Post(message: message, url: url, userId: userId, timestamp: timestamp))
                    trackUrls.append(url)
                }
                
                self.posts.sort { $0.timestamp > $1.timestamp }
                
                Spotify.shared.api.tracks(trackUrls).sink { completion in
                    if case .failure(let error) = completion {print("couldn't get tracks: \(error)")}
                } receiveValue: { tracks in
                    for track in tracks {
                        if let unwrappedTrack = track {
                            self.tracks[unwrappedTrack.uri ?? ""] = unwrappedTrack
                        }
                    }
                    self.cacheTrackImages()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                .store(in: &Spotify.shared.cancellables)
            }
        })
    }

    
    func setupTableView() {
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "JustinCell")
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
