//
//  DiscoverController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/19/21.
//

import UIKit
import Koloda
import SpotifyWebAPI
import AVFoundation

class DiscoverController: UIViewController, KolodaViewDelegate, KolodaViewDataSource {
    @IBOutlet weak var cardSwiper: KolodaView!
    
    
    
    var recommended: RecommendationsResponse!
    var songs: [Song] = []
    var albumCovers: [String] = []
    var likedSongs: [SpotifyURIConvertible] = []
    var userURI: SpotifyURIConvertible?
    var spotifyCreatedPlaylist: Playlist<PlaylistItems>?
    var player = AVAudioPlayer()
    var userAttributes = [0.5,0.5,0.5,0.5,0.5]
    var seedTracks: [SpotifyURIConvertible] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardSwiper.dataSource = self
        cardSwiper.delegate = self
        setup()
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let currentSong = songs[index]
        
        let discoverCard = UIView(frame: koloda.bounds)
        discoverCard.layer.borderWidth = 1
        discoverCard.layer.borderColor = UIColor.black.cgColor
        discoverCard.layer.cornerRadius = 10
        let theImageFrame = CGRect(x: discoverCard.frame.midX-144, y: 20, width:288, height: 288)
        let imageView = UIImageView(frame: theImageFrame)
        imageView.image = currentSong.albumCover
        //imageView.contentMode = .scaleAspectFit
        let discoverCardColor = currentSong.albumCover?.averageColor
        let textColor = discoverCardColor!.isDarkColor ? UIColor.white : UIColor.black
        discoverCard.backgroundColor = discoverCardColor
        discoverCard.addSubview(imageView)
    
        var theTextFrame = CGRect(x: discoverCard.frame.midX - 144, y: 318, width: 288, height: 30)
        var textView = UILabel(frame: theTextFrame)
        textView.text = currentSong.title
        textView.textAlignment = .left
        textView.textColor = textColor
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        discoverCard.addSubview(textView)
        
        theTextFrame = CGRect(x: discoverCard.frame.midX - 144, y: 348, width: 288, height: 30)
        textView = UILabel(frame: theTextFrame)
        textView.text = currentSong.artist
        textView.textAlignment = .left
        textView.textColor = textColor
        textView.font = UIFont.systemFont(ofSize: 16)
        discoverCard.addSubview(textView)
        
        theTextFrame = CGRect(x: discoverCard.frame.midX - 144, y: 378, width: 288, height: 30)
        textView = UILabel(frame: theTextFrame)
        textView.text = currentSong.album
        textView.textAlignment = .left
        textView.textColor = textColor
        textView.font = UIFont.systemFont(ofSize: 16)
        discoverCard.addSubview(textView)
        
        return discoverCard
    }
    @IBAction func newSession(_ sender: Any) {
        player.stop()
        songs = []
        self.cardSwiper.reloadData()
        if likedSongs.count != 0 {
            createDiscoverPlaylist()
            //updateUserAttributes()
            updateSeed()
        }
        setup()
    }
    @IBAction func endSession(_ sender: Any) {
        player.stop()
        songs = []
        self.cardSwiper.reloadData()
        if likedSongs.count != 0 {
            createDiscoverPlaylist()
            //updateUserAttributes()
            updateSeed()
        }
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return songs.count
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection){
        if direction == SwipeResultDirection.right {
                // implement your functions or whatever here
            likedSongs.append("spotify:track:\(songs[index].id)")
           } else if direction == .left {
           // implement your functions or whatever here
               print("user swiped left")
           }
    }
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        player.stop()
        if likedSongs.count != 0 {
            createDiscoverPlaylist()
            //updateUserAttributes()
            updateSeed()
        }
    }
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        playSong(url: songs[koloda.currentCardIndex].preview!)
    }
    func setup(){
        seedTracks = UserDefaults.standard.object(forKey: "userSeedTracks") as? [SpotifyURIConvertible] ?? []
        print("Seed Tracks: \(seedTracks)")
        print(UserDefaults.standard.object(forKey: "userSeedTracks") ?? "oopsie whoopsie")
        if seedTracks.isEmpty {
            Spotify.shared.api.currentUserTopTracks(TimeRange.shortTerm, limit: 5)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: {
                    completion in if case .failure(let error) = completion {print("couldn't get top tracks: \(error)")}
                    self.seedTracks = ["spotify:track:0LDiaSudHOYJ8e473mv5uY"]
                    self.fetchData()
                }, receiveValue: { topTracksResponse in
                    self.seedTracks = []
                    for track in topTracksResponse.items {
                        if track.id != nil {
                            self.seedTracks.append("spotify:track:\(track.id!)")
                        }
                    }
                    print("Top Tracks: \(self.seedTracks)")
                    self.fetchData()
                }
            )
            .store(in: &Spotify.shared.cancellables)
            
        }
        
    }
    func fetchData() {
        //acousticness: AttributeRange(min: Double(userAttributes[0]) - 0.05, target: Double(userAttributes[0]), max: Double(userAttributes[0]) + 0.05)
        print(userAttributes)
        Spotify.shared.api.recommendations(TrackAttributes(seedTracks: seedTracks))
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: {
                    completion in if case .failure(let error) = completion {print("couldn't retrieve playlist: \(error)")}
                    
                }, receiveValue: { recommended in
                    self.recommended = recommended
                    self.parseData(response: recommended)
                
                    
                }
            )
            .store(in: &Spotify.shared.cancellables)
    }
    
    func parseData(response: RecommendationsResponse) {
        let tracks = response.tracks
        var artistName = ""
        var albumName = ""
        var trackId = ""
        for track in tracks {
            if track.previewURL != nil  {
                //print("PreviewURL: \(track.previewURL)")
                let title = track.name
                if let album = track.album {
                    albumName = album.name
                    if let images = album.images {
                        if images.isEmpty{
                            albumCovers.append("")
                        }
                        else {
                            albumCovers.append(images[0].url.absoluteString)
                        }
                    }
                }
                if let artists = track.artists{
                    artistName = ""
                    for i in 0..<artists.count{
                        artistName += "\(artists[i].name)"
                        if i < (artists.count - 1) {
                            artistName += ", "
                        }
                        
                    }
                }
                if track.id != nil {
                    trackId = track.id!
                }
                if let artists = track.artists {
                    artistName = artists.splitByComma()

                }
                let song = Song(albumCover: UIImage(named: "song-placeholder"), title: title, artist: artistName, album: albumName, id: trackId, preview: track.previewURL)
                songs.append(song)
                

            }
           
        }
        cacheImages()
    }
    
    func cacheImages() {
        for i in 0..<albumCovers.count {
                let url = URL(string: albumCovers[i])
                let data = try? Data(contentsOf: url!)
                var image = UIImage(named: "song-placeholder")
                if data != nil {
                    image = UIImage(data: data!)
                }
            songs[i].albumCover = image
            
        }
        self.cardSwiper.reloadData()
    }
    func updateUserAttributes() {
        Spotify.shared.api.tracksAudioFeatures(likedSongs)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion:  {
                    completion in if case .failure(let error) = completion {print("couldn't find track attributes: \(error)")}
                }, receiveValue: { attributes in
                    self.handleAttributes(attributes: attributes)
                }
            )
            .store(in: &Spotify.shared.cancellables)
    }
    func handleAttributes(attributes: [AudioFeatures?]){
        var acousticness = 0.0
        var danceability = 0.0
        var energy = 0.0
        var instrumentalness = 0.0
        var valence = 0.0
        for data in attributes {
            if let _ = data?.acousticness {
                acousticness += data!.acousticness
            }
            if let _ = data?.danceability {
                danceability += data!.danceability
            }
            if let _ = data?.energy {
                energy += data!.energy
            }
            if let _ = data?.instrumentalness {
                instrumentalness += data!.instrumentalness
            }
            if let _ = data?.valence {
                valence += data!.valence
            }
        }
   
        let newAttributes = [acousticness/Double(attributes.count),danceability/Double(attributes.count),energy/Double(attributes.count),instrumentalness/Double(attributes.count), valence/Double(attributes.count)]
        let oldAttributes = UserDefaults.standard.object(forKey: "userAttributes") as? [Double] ?? [0.5,0.5,0.5,0.5,0.5]
        var updatedAttributes = [0.0,0.0,0.0,0.0,0.0]
        for i in 0...4{
            let weightedNew = 0.4*newAttributes[i]
            let weightedOld = 0.6*oldAttributes[i]
            updatedAttributes[i] = Double(weightedOld + weightedNew)
        }
        print(updatedAttributes)
        UserDefaults.standard.setValue(updatedAttributes, forKey: "userAttributes")
        
    }
    func createDiscoverPlaylist() {
        let now = Date()

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium

        let datetime = formatter.string(from: now)
        let playlistName = "Arpeggio Discover Session \(datetime)"
        let playlistDescription = "Playlist from your Arpeggio Discover Session on \(datetime)"
        let playlistDetails = PlaylistDetails(name: playlistName, description: playlistDescription)
        Spotify.shared.api.createPlaylist(for: Spotify.shared.currentUser?.uri as! SpotifyURIConvertible, playlistDetails)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: {
                    completion in if case .failure(let error) = completion {print("couldn't create playlist: \(error)")}
                    
                }, receiveValue: { createdPlaylist in
                    self.spotifyCreatedPlaylist = createdPlaylist
                    //self.addDiscoveredSongsToPlaylist(createdPlaylist.uri)
                    print(createdPlaylist)
                    self.addToPlaylist(uri: createdPlaylist.uri)
                    
                }
            )
            .store(in: &Spotify.shared.cancellables)
    }
    
    func addToPlaylist(uri: SpotifyURIConvertible) {
        Spotify.shared.api.addToPlaylist(uri, uris: likedSongs)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: {
                    completion in if case .failure(let error) = completion {print("couldn't add to playlist: \(error)")}
                    
                }, receiveValue: { addedReturn in
                    print("After add: \(addedReturn)")
                }
            )
            .store(in: &Spotify.shared.cancellables)
        
    }
    func playSong(url: URL) {
        downloadFileFromURL(url: url)
    }
    func downloadFileFromURL(url: URL){
            var downloadTask = URLSessionDownloadTask()
            downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
                customURL, response, error in

                self.play(url: customURL!)

            })

            downloadTask.resume()


        }

    func play(url: URL) {

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()

        }
        catch{
            print(error)
        }
        
    }
    func updateSeed() {
        var newSeedTracks: [SpotifyURIConvertible] = []
        if likedSongs.count < 5 {
            for i in 0..<likedSongs.count {
                newSeedTracks.append(likedSongs[i])
            }
        }
        else {
            for i in 0...4 {
                newSeedTracks.append(likedSongs[i])
            }
        }
        print("New Seed Tracks: \(newSeedTracks)")
        UserDefaults.standard.setValue(newSeedTracks, forKey: "userSeedTracks")
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
extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
extension UIColor
{
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}

struct Song {
    var albumCover: UIImage?
    let title: String?
    let artist: String?
    let album: String?
    let id: String
    let preview: URL?
}
struct ArpeggioAttributes {
    var acousticness: Double? //A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic.
    var danceability: Double? //Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.
    var energy: Double? //Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.
    var instrumentalness: Double? //Predicts whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0.
    var valence: Double? //A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
}
