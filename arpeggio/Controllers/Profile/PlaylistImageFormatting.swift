//
//  PlaylistImageFormatting.swift
//  arpeggio
//
//  Created by Jihoun Im on 12/2/21.
//

import UIKit

// MARK: - Collection View Flow Layout Delegate
extension ProfileController: UICollectionViewDelegateFlowLayout {
//    let itemsPerRow: CGFloat = 1
//    let sectionInsets = UIEdgeInsets(
//        top: 10.0,
//        left: 10.0,
//        bottom: 10.0,
//        right: 10.0
//    )
    
  // 1
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    // 2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  // 3
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return sectionInsets.left
  }
}
