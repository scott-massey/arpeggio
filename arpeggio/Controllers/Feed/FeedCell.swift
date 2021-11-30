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
    
}
