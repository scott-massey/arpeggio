//
//  SearchController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/30/21.
//

import UIKit
import SpotifyWebAPI

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var searchResults: [Track] = []
    var imageCache: [String: UIImage] = [:]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    weak var delegate: SearchTrackDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchCellController ?? SearchCellController(style: .default, reuseIdentifier: "SearchCell")
        
        let track = searchResults[indexPath.row]
        
        myCell.albumCover.image = imageCache[track.id ?? ""] ?? imageCache["default"]
        myCell.songName.text = track.name
        let artists = track.artists?.splitByComma()
        let albumName = track.album?.name
        
        myCell.artistAlbum.text = "\(albumName ?? "") | \(artists ?? "")"
        
        return myCell
    }
    
    /* MARK: PLAN
     Create callback when item is selected to trigger back action
     during segue, send selected value to parent
     You'll likely need to cast the presentingViewController as "PostsViewController"
     See Followers (either) for an example of how this works
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = searchResults[indexPath.row]
        // use presentingViewController and cast as parent VC (either discover or search)
        // then set a member variable of the parent view controller
        delegate?.trackWasChosen(track: selectedTrack)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query = searchBar.text ?? ""
        
        Spotify.shared.api.search(query: query, categories: [.track])
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Couldn't search, error: \(error)")
                }
            }, receiveValue: { searchResult in
                self.searchResults = searchResult.tracks?.items ?? []
                self.cacheImages()
                self.tableView.reloadData()
            })
            .store(in: &Spotify.shared.cancellables)
    }
    
    func cacheImages() {
        for track in searchResults {
            let imageUrl = track.album?.images?[0].url
            let data = try? Data(contentsOf: imageUrl!)
            var image = UIImage(named: "song-placeholder")
            if (data != nil) {
                image = UIImage(data: data!)
            }
            imageCache[track.id ?? ""] = image
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        imageCache["default"] = UIImage(named: "song-placeholder")
    }
}

protocol SearchTrackDelegate: AnyObject {
    func trackWasChosen(track: Track)
}
