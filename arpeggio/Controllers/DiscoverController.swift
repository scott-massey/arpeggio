//
//  DiscoverController.swift
//  arpeggio
//
//  Created by Jacob Cytron on 11/12/21.
//

import UIKit
import SpotifyWebAPI
//Spotify.shared.API.authorize

class DiscoverController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
    var songs: [Song] = [Song(title: "Leave the Door Open"), Song(title: "Skate"), Song(title: "Smokin' Out the Window")]
    var recommended: RecommendationsResponse!
    var albumCovers: [String] = []
    var theImageCache: [UIImage] = []
    
    @IBOutlet weak var discoverView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        discoverView.dataSource = self
        discoverView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 400)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.headerReferenceSize = CGSize(width: 0, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        discoverView.collectionViewLayout = layout
        fetchData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        theImageCache.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let song = songs[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCard", for: indexPath) as! DiscoverCell
        cell.set(cover: theImageCache[indexPath.row] , title: "Song Title Here")
        
        return cell
    }
    
    func fetchData() {
        Spotify.shared.api.recommendations(TrackAttributes(seedTracks: ["spotify:track:0LDiaSudHOYJ8e473mv5uY"]))
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: {
                    completion in if case .failure(let error) = completion {print("couldn't retrieve playlist: \(error)")}
                    
                }, receiveValue: { recommended in
                    self.recommended = recommended
                    self.parseData(response: recommended)
                    print(recommended)
                    
                }
            )
            .store(in: &Spotify.shared.cancellables)
    }
    
    func parseData(response: RecommendationsResponse) {
        let tracks = response.tracks
        for track in tracks{
            if let album = track.album {
                if let images = album.images {
                    if images.isEmpty{
                        albumCovers.append("")
                    }
                    else {
                        albumCovers.append(images[0].url.absoluteString)
                    }
                }
            }
        }
            
        for url in albumCovers{
            print("ALBUM COVER URL: \(url)")
        }
        cacheImages()
    }
    
    func cacheImages() {
        for coverUrl in albumCovers {
                let url = URL(string: coverUrl)
                let data = try? Data(contentsOf: url!)
                var image = UIImage(named: "song-placeholder")
                if data != nil {
                    image = UIImage(data: data!)
                }
            theImageCache.append(image!)
            
        }
        self.discoverView.reloadData()
    }
}

struct Song: Decodable {
    let title: String
}

