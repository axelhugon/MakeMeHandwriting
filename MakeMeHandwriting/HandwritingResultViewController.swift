//
//  HandwritingResultViewController.swift
//  MakeMeHandwriting
//
//  Created by Axel Hugon on 09/01/2017.
//  Copyright © 2017 AHUGON. All rights reserved.
//

import UIKit

class HandwritingResultViewController: UIViewController {
    
    //Objects from the storyboard
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var doItAgainButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var handwritingResultImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
