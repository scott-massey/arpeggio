//
//  FollowingDisplayTableViewCell.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/16/21.
//

import UIKit

class FollowingDisplayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingName: UILabel!
    
    var spotifyUserURI: String!
    var FBUID: String!
}
