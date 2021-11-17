//
//  FeedViewController.swift
//  arpeggio
//
//  Created by Justin Pressman on 11/11/21.
//

import UIKit
import Combine
import KeychainAccess
import SpotifyWebAPI
import Firebase
import FirebaseDatabase

var currentPosts: [[String: String?]] = []

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "JustinCell")! as UITableViewCell
        let stringTest = "Test Post"
        myCell.textLabel!.text = stringTest
        return myCell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        //Sets the navigation title with text and image
        self.navigationItem.titleView = navTitleWithImageAndText(imageName: "Logo")
        getData()
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
    
    func getData() {
        guard let fbUser = Spotify.shared.currentFBUser else { return }
        Database.database().reference()
            .child("users")
            .child(fbUser.uid)
            .child("posts")
            .getData(completion:  { error, snapshot in
              guard error == nil else {
                print(error!.localizedDescription)
                return;
              }
                
                //currentPosts.append(contentsOf: value2)
            });
    }

    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "JustinCell")
        tableView.dataSource = self
        tableView.delegate = self
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
