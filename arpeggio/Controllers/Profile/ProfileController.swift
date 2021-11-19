//
//  ProfileController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/10/21.
//

import UIKit
import Combine
import SpotifyWebAPI

class ProfileController: UIViewController, UICollectionViewDataSource,  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Constants
    let itemsPerRow: CGFloat = 1
    let sectionInsets = UIEdgeInsets(
        top: 10.0,
        left: 10.0,
        bottom: 10.0,
        right: 10.0
    )
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var cancellables: Set<AnyCancellable> = []
    var playlists: [Playlist<PlaylistItemsReference>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCollectionView()
        getProfileImage()
        getPlaylists()
        
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func getProfileImage() {
        guard let unwrappedProfileImageUrl = Spotify.shared.currentUser?.images?[0].url
        else {
            print("Error: could not retrieve profile image")
            return
        }
                
        do {
            let data = try Data(contentsOf: unwrappedProfileImageUrl)
            let image = UIImage(data: data)
            profileImage.image = image
        } catch {
            print("Error: could not show image")
        }
    }
    
    func getPlaylists() {
        // change this
        guard let user = Spotify.shared.currentUser else {
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        collectionView.addSubview(activityIndicator)
        activityIndicator.frame = collectionView.bounds
        activityIndicator.startAnimating()
        
        Spotify.shared.api.userPlaylists(for: user.uri, limit: 3)
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
    
    @IBAction func logOut(_ sender: Any) {
        Spotify.shared.api.authorizationManager.deauthorize()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let loginController = storyboard.instantiateViewController(identifier: "Login")
           
           // This is to get the SceneDelegate object from your view controller
           // then call the change root view controller function to change to main tab bar
           (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginController)
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
                if playlist.images.count >= 3 {
                    let data = try Data(contentsOf: playlist.images[1].url)
                    let image = UIImage(data: data)
                    unwrappedCell.imageView.image = image
                }
            } catch {
                print("Error: could not show image")
            }

            return unwrappedCell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
                
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
      
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
      ) -> UIEdgeInsets {
        return sectionInsets
    }
      
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
      ) -> CGFloat {
        return sectionInsets.left
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = playlists[indexPath.item].externalURLs?["spotify"]
        
        if let unwrappedURL = url {
            if UIApplication.shared.canOpenURL(unwrappedURL) {
                UIApplication.shared.open(unwrappedURL)
            }
        }
    }
}
