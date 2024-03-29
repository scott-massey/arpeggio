//
//  PostsViewController.swift
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

class PostsViewController: UIViewController, SearchTrackDelegate {
    
    
    @IBOutlet weak var trackInput: UITextField!
    @IBOutlet weak var captionOutlet: UITextField!
    
    var selectedTrack: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func finishPosting(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showSearch(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SearchTrack") as? SearchController {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func arpeggioPost(_ sender: Any) {
        self.createFirebasePost()
        self.dismiss(animated: true)
    }
    
    func createFirebasePost() {
        guard let fbUser = Spotify.shared.currentFBUser else { return }
        //let postURL = trackInput.text
        let message = captionOutlet.text
        
        let postDict = ["url": (selectedTrack?.uri ?? "") as String, "message": message ?? "", "userId":fbUser.uid, "timestamp": TimeInterval(NSDate().timeIntervalSince1970) as NSNumber] as [String : Any]
        
        Database.database().reference()
            .child("posts")
            .child(UUID().uuidString)
            .setValue(postDict)
        //currentPosts.append(postDict)
    }

    func trackWasChosen(track: Track) {
        trackInput.text = track.name
        selectedTrack = track
    }


}
