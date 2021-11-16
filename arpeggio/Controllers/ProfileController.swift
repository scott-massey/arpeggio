//
//  ProfileController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/12/21.
//

import UIKit

class ProfileController: UIViewController, UICollectionViewDataSource,  UICollectionViewDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCollectionView()
        getProfileImage()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func getProfileImage() {
        guard let unwrappedProfileImageUrl = Spotify.shared.currentUser?.images?[0].url
        else {
            print("Error: could not retrieve profile image")
            return
        }
                
        do {
            let data = try Data(contentsOf: unwrappedProfileImageUrl)
            let image = UIImage(data: data)
            profileImage.image = image
        } catch {
            print("Error: could not show image")
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        Spotify.shared.api.authorizationManager.deauthorize()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let loginController = storyboard.instantiateViewController(identifier: "Login")
           
           // This is to get the SceneDelegate object from your view controller
           // then call the change root view controller function to change to main tab bar
           (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginController)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
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
