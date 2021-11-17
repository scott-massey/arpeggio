//
//  FollowingDisplayTableViewCell.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/11/21.
//

import UIKit

class FollowingDisplayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingName: UILabel!
    
    var spotifyUserURI: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
