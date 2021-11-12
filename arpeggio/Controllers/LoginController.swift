//
//  ViewController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/7/21.
//

import UIKit
import Combine
import KeychainAccess
import SpotifyWebAPI

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func initiateSignIn(_ sender: Any) {
        Spotify.shared.authorize()
    }
    
}
