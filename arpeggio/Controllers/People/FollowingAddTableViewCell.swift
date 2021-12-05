//
//  FollowingAddTableViewCell.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/11/21.
//

import UIKit

class FollowingAddTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    
    var spotifyUserURI: String!
    var FBUID: String!
}
