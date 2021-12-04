//
//  DiscoverWelcomeController.swift
//  arpeggio
//
//  Created by Jacob Cytron on 12/1/21.
//

import Foundation
import UIKit
import SpotifyWebAPI


class DiscoverWelcomeController: UIViewController, SearchTrackDelegate {
    
    @IBOutlet weak var seedLabel: UILabel!
    @IBOutlet weak var seedSelect: UITextField!
    var seedTrack = ""
    @IBOutlet weak var seedTrackPrefs: UISegmentedControl!
    @IBOutlet weak var destinationSelect: UISegmentedControl!
    var toLikedSongs = false
    
    override func viewDidLoad() {
        seedLabel.isHidden = seedTrackPrefs.selectedSegmentIndex == 0
        seedSelect.isHidden = seedTrackPrefs.selectedSegmentIndex == 0
        toLikedSongs = destinationSelect.selectedSegmentIndex == 1
        self.navigationItem.titleView = navTitleWithImageAndText(imageName: "Logo")
    }
    @IBAction func seedPrefChange(_ sender: Any) {
        viewDidLoad()
    }
    @IBAction func destinationChange(_ sender: Any) {
        viewDidLoad()
    }
    
    @IBAction func showSearch(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SearchTrack") as? SearchController {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
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
    
    func trackWasChosen(track: Track) {
        seedSelect.text = track.name
        seedTrack = track.uri ?? ""
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DiscoverController {
            let vc = segue.destination as? DiscoverController
            if seedTrack != "" && seedTrackPrefs.selectedSegmentIndex == 1{
                vc?.seedTracks = [seedTrack]
            }
            vc?.customSeed = seedTrackPrefs.selectedSegmentIndex == 1
            vc?.toLikedSongs = toLikedSongs
        }
    }
    
    
}
