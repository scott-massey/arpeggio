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

class PostsViewController: UIViewController {

    @IBOutlet weak var titleOutlet: UITextField!
    @IBOutlet weak var artistOutlet: UITextField!
    @IBOutlet weak var urlOutlet: UITextField!
    @IBOutlet weak var captionOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func arpeggioPost(_ sender: Any) {
        self.createFirebasePost()
        self.dismiss(animated: true)
    }
    
    func createFirebasePost() {
        guard let fbUser = Spotify.shared.currentFBUser else { return }
        let postTitle = titleOutlet.text
        let postArtist = artistOutlet.text
        let postURL = urlOutlet.text
        let postCaption = captionOutlet.text
        
        let postDict = ["title": postTitle, "artist": postArtist, "url": postURL, "caption": postCaption]
        
        Database.database().reference()
            .child("users")
            .child(fbUser.uid)
            .child("posts")
            .setValue([
                "post": postDict
            ])
        currentPosts.append(postDict)
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
