//
//  PostsViewController.swift
//  arpeggio
//
//  Created by Justin Pressman on 11/16/21.
//

import UIKit
import Combine
import KeychainAccess
import SpotifyWebAPI

class PostsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func arpeggioPost(_ sender: Any) {
        self.createFirebasePost()
        self.dismiss(animated: true)
    }
    
    func createFirebasePost() {
        
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
