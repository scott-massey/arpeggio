//
//  FollowingAddTableViewCell.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/16/21.
//

import UIKit

class FollowingAddTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    
    var spotifyUserURI: String!
    var FBUID: String!
    
    var currentFollowingList: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func followAccount(_ sender: Any) {
        Followers.shared.updateCurrentFollowings(FBUID: FBUID)
    }
}
