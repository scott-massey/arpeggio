//
//  DiscoverCell.swift
//  arpeggio
//
//  Created by Jacob Cytron on 11/15/21.
//

import Foundation
import UIKit

class DiscoverCell: UICollectionViewCell {
    
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    
    func set(cover: UIImage?, title: String) {
        self.songTitle.text = title
        guard cover != nil else { self.albumCover.image = UIImage(named: "song-placeholder"); return}
        self.albumCover.image = cover!
    }
    
    
}
