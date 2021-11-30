//
//  FirebaseUserDetails.swift
//  arpeggio
//
//  Created by Jihoun Im on 11/11/21.
//

import Foundation

struct FirebaseUserDetails: Equatable {
    var displayName: String
    var imageURL: String
    var spotifyUserURI: String
    var FBUID: String
    
    static func == (lhs: FirebaseUserDetails, rhs: FirebaseUserDetails) -> Bool {
        return lhs.FBUID == rhs.FBUID
    }
}
