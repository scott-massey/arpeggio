//
//  ProfileController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/10/21.
//

import UIKit
import Combine
import SpotifyWebAPI

class ProfileController: UIViewController, UICollectionViewDataSource,  UICollectionViewDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var profileInfoView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followers: UILabel!
    
    var selectedUser: FirebaseUserDetails?
    var viewType: ProfileViewType = .ownProfile
    
    var cancellables: Set<AnyCancellable> = []
    var playlists: [Playlist<PlaylistItemsReference>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupBackgroundView()
        setupProfileInfoView()

        getProfileImage()
        getPlaylists()
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        if let _ = selectedUser {
            navBar.title = "\(selectedUser?.displayName ?? "Unknown")'s Profile"
            guard let button = navBar.rightBarButtonItem?.customView as? UIButton else { return }
            
            name.text = selectedUser?.displayName
            followers.text = ""
            followerCount.text = ""
            
            switch viewType {
                case .following:
                    button.setTitle("Unfollow", for: .normal)
                    
                default:
                    button.setTitle("Follow", for: .normal)
            }
        } else {
            navBar.title = "Your Profile"
        }
    }
    
    func setupBackgroundView() {
        backgroundView.layer.cornerRadius = 10
    }
    
    func setupProfileInfoView() {
        profileInfoView.layer.cornerRadius = 10
        profileInfoView.layer.shadowColor = UIColor.black.cgColor
        profileInfoView.layer.shadowOpacity = 0.3
        profileInfoView.layer.shadowOffset = .zero
        profileInfoView.layer.shadowRadius = 10
        
        name.text = Spotify.shared.currentUser?.displayName
        followerCount.text = String(Spotify.shared.followingInfo.count)
    }
    
    func getProfileImage() {
        guard let unwrappedProfileImageUrl = selectedUser == nil ? Spotify.shared.currentUser?.images?[0].url : URL(string: selectedUser!.imageURL)
        else {
            print("Error: could not retrieve profile image")
            return
        }
                
        do {
            let data = try Data(contentsOf: unwrappedProfileImageUrl)
            if let image = UIImage(data: data) {
                let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 300.0, height: 300.0))
                profileImage.image = resizedImage
            }
        } catch {
            print("Error: could not show image")
        }
    }
    
    func getPlaylists() {
        guard let user = Spotify.shared.currentUser else {
            return
        }
        
        let uri = selectedUser == nil ? user.uri : selectedUser!.spotifyUserURI
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        collectionView.addSubview(activityIndicator)
        activityIndicator.frame = collectionView.bounds
        activityIndicator.startAnimating()
        
        Spotify.shared.api.userPlaylists(for: uri, limit: 4)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("couldn't retrieve current user: \(error)")
                    }
                },
                receiveValue: { result in
                    self.playlists = result.items
                    activityIndicator.removeFromSuperview()
                    self.collectionView?.reloadData()
                }
            )
            .store(in: &cancellables)
    }
    
    @IBAction func onNavPress(_ sender: Any) {
        switch viewType {
        case .addFollowing:
            Spotify.shared.follow(followingId: selectedUser?.FBUID ?? "")
            break
        case .following:
            Spotify.shared.unFollow(userId: selectedUser?.FBUID ?? "")
            break
        default:
            Spotify.shared.api.authorizationManager.deauthorize()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let loginController = storyboard.instantiateViewController(identifier: "Login")
               
               // This is to get the SceneDelegate object from your view controller
               // then call the change root view controller function to change to main tab bar
               (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginController)
            break
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Cell",
            for: indexPath
        ) as? PlaylistCollectionViewCell

        let playlist = playlists[indexPath.row]

        if let unwrappedCell = cell {
            unwrappedCell.backgroundColor = UIColor.white

            do {
                if playlist.images.count > 0 {
                    let data = try Data(contentsOf: playlist.images[0].url)
                    let image = UIImage(data: data)
                    if let unwrappedImage = image {
                        let formattedImage = resizeImage(image: unwrappedImage, targetSize: CGSize(width: 180.0, height: 180.0))
                        unwrappedCell.imageView.image = formattedImage
                    } else {
                        unwrappedCell.imageView.image = image
                    }
                    
                } else {
                    //no image, need to display an image not found image
                }
            } catch {
                print("Error: could not show image")
            }

            return unwrappedCell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = playlists[indexPath.item].externalURLs?["spotify"]
        
        if let unwrappedURL = url {
            if UIApplication.shared.canOpenURL(unwrappedURL) {
                UIApplication.shared.open(unwrappedURL)
            }
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

enum ProfileViewType {
    case following, addFollowing, ownProfile
}
