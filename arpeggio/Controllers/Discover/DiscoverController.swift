//
//  DiscoverController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/19/21.
//

import UIKit
import Koloda
import SpotifyWebAPI

class DiscoverController: UIViewController, KolodaViewDelegate, KolodaViewDataSource {
    @IBOutlet weak var cardSwiper: KolodaView!
    
    
    
    var recommended: RecommendationsResponse!
    var songs: [Song] = []
    var albumCovers: [String] = []
    var likedSongs: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardSwiper.dataSource = self
        cardSwiper.delegate = self
        fetchData()
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
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return songs.count
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection){
        if direction == SwipeResultDirection.right {
                // implement your functions or whatever here
            likedSongs.append(songs[index].id)
               print("user swiped right")
           } else if direction == .left {
           // implement your functions or whatever here
               print("user swiped left")
           }
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
                    //print(recommended)
                    
                }
            )
            .store(in: &Spotify.shared.cancellables)
    }
    
    func parseData(response: RecommendationsResponse) {
        let tracks = response.tracks
        var artistName = ""
        var albumName = ""
        var trackId = ""
        for track in tracks{
            print("Track: \(track)")
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
                    print("Artist: \(artists[i].name)")
                    if i < (artists.count - 1) {
                        artistName += ", "
                    }
                    
                }
            }
            if track.id != nil {
                trackId = track.id!
            }
            
            let song = Song(albumCover: UIImage(named: "song-placeholder"), title: title, artist: artistName, album: albumName, id: trackId)
            songs.append(song)
        }
            
//        for url in albumCovers{
//            print("ALBUM COVER URL: \(url)")
//        }
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
    func randomColor() -> UIColor {

          return UIColor(red: randomFloat(), green: randomFloat(), blue: randomFloat(), alpha: 1)

      }
    func randomFloat() -> CGFloat {

        return CGFloat(arc4random()) / CGFloat(UInt32.max)

    }
    func newTextView(text: String, y: Int) -> UIView {
        let theTextFrame = CGRect(x: Int(view.frame.midX) - 150, y: y, width: 300, height: 30)
        let textView = UILabel(frame: theTextFrame)
        textView.text = text
        textView.textAlignment = .center
        textView.textColor = .black
        return textView
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
}
struct ArpeggioAttributes: Decodable {
    let danceability: Float? //Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.
    let energy: Float? //Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.
    let instrumentalness: Float? //Predicts whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0.
    let loudness: Float? //The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typically range between -60 and 0 db.
    let valence: Float? //A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
}
