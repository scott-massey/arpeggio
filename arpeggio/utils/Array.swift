//
//  Array.swift
//  arpeggio
//
//  Created by Scott Massey on 11/30/21.
//

import SpotifyWebAPI

extension Array where Element == Artist {
    func splitByComma() -> String {
        var artistName = ""
        for i in 0..<self.count{
            artistName += "\(self[i].name)"
            print("Artist: \(self[i].name)")
            if i < (self.count - 1) {
                artistName += ", "
            }
            
        }
        return artistName
    }
}
