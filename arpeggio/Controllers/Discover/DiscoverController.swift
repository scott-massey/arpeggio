//
//  DiscoverController.swift
//  arpeggio
//
//  Created by Scott Massey on 11/19/21.
//

import UIKit
import Koloda

class DiscoverController: UIViewController, KolodaViewDelegate, KolodaViewDataSource {
    @IBOutlet weak var cardSwiper: KolodaView!
    
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return UIImageView(image: UIImage(named: data[index])!)
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return data.count
    }
    
    
    let data = ["puppy1", "puppy2", "puppy3"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardSwiper.dataSource = self
        cardSwiper.delegate = self
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
