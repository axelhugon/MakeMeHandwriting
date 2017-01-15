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
    
    
    // Variables
    var handwritingPngImage = UIImage()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.handwritingResultImage.image = self.handwritingPngImage

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func onDoItAgainButtonTouched(_ sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewControllerId") as! ViewController
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    @IBAction func onShareButtonTouchUpInside(_ sender: Any) {
        
        // image to share
        let image = handwritingPngImage
        
        // set up activity view controller
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    

}
