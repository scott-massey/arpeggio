//
//  FeedViewController.swift
//  arpeggio
//
//  Created by Justin Pressman on 11/16/21.
//

import UIKit
import Combine
import KeychainAccess
import SpotifyWebAPI

class FeedViewController: UIViewController {

    override func viewDidLoad() {

        super.viewDidLoad()

        //Sets the navigation title with text and image
        self.navigationItem.titleView = navTitleWithImageAndText(imageName: "Logo")
    }

    func navTitleWithImageAndText(imageName: String) -> UIView {

        let titleView = UIView()

        // Creates the image view
        let image = UIImageView()
        image.image = UIImage(named: imageName)
        image.frame = CGRect(x: -40, y: -10, width: 80, height: 21)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        titleView.addSubview(image)
        titleView.sizeToFit()
        return titleView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
