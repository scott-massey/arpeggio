//
//  PostsController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/30/21.
//

import UIKit

class FeedCell: UITableViewCell {
    var poster: FirebaseUserDetails! {
        didSet {
            posterName.text = poster.displayName
        }
    }
    
    
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var artistAlbum: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        albumArt.addGestureRecognizer(tapGR)
        albumArt.isUserInteractionEnabled = true
    }
    
    
    var trackId: String?
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            guard trackId != nil else { return }
            
            if let url = URL(string: "https://open.spotify.com/track/\(trackId!)") {
                UIApplication.shared.open(url)
            }
        }
    }
    
}
