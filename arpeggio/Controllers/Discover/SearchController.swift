////
////  SearchController.swift
////  arpeggio
////
////  Created by Jacob Cytron on 11/30/21.
////
//
//import Foundation
//import UIKit
//import SpotifyWebAPI
//
//class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var songList: UITableView!
//
//    var returnedSongs: [String] = []
//
//    override func viewDidLoad() {
//        //code
//        songList.delegate = self
//        songList.dataSource = self
//    }
//
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return returnedSongs.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return UITableViewCell()
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let query = sanitizeQuery(query: searchBar.text ?? "")
//        print(query)
//        Spotify.shared.api.search(query: query, categories: [IDCategory.track])
//            .receive(on: RunLoop.main)
//            .sink(
//                receiveCompletion: {
//                    completion in if case .failure(let error) = completion {print("couldn't search: \(error)")}
//
//                }, receiveValue: { searchResult in
//                   print("Search Results: \(searchResult)")
//                }
//            )
//            .store(in: &Spotify.shared.cancellables)
//
//    }
//
//    func sanitizeQuery(query: String) -> String {
//        return query
//    }
//    func fetchData() {
//
//    }
//}
