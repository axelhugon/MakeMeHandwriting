//
//  LoadingViewController.swift
//  MakeMeHandwriting
//
//  Created by Axel Hugon on 09/01/2017.
//  Copyright © 2017 AHUGON. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    //Objects from the Storyboard
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    
    //Variables
    ///Text typed from Home
    private var typedText: String = ""
    private var selectedFontId: String = ""
    private var selectedColor: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callHWApi()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Setter
    func setTypedText(typedText : NSString!){
        self.typedText = typedText as String
    }
    
    func setFontId(fontId: NSString!){
        self.selectedFontId = fontId as String
    }
    
    func setColor(color: NSString!){
        self.selectedColor = color as String
    }
    

    // MARK: - API
    fileprivate func callHWApi(){
        // All fields are validated, call the API to transform the user's input text into a handwrited text
        HandwriteTextManager.sharedInstance.getRenderText(self.typedText, fontId: self.selectedFontId , color: self.selectedColor, fontSize: "30px", height: "auto", width: "\(self.view.frame.width)px") { (renderObject: Render?, error: HandwriteError?) in
            
            guard error == nil else {
                // An error occured display an error message in an alert view
                self.showStandardErrorAlertView()
                return
            }
            
            guard renderObject != nil else {
                // If the render object is nil, An error occured display an error message in an alert view
                self.showStandardErrorAlertView()
                return
                
                
            }
            
            // Send the generated result image in the next view
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HandwritingViewControllerId") as! HandwritingResultViewController
            nextViewController.handwritingPngImage = renderObject!.handwritedTextImage
            self.present(nextViewController, animated:true, completion:nil)
        }
    }

    fileprivate func showStandardErrorAlertView(){
        /// Create an alert with the error message
        let alert = UIAlertController(title: "Oups", message: "An error occured", preferredStyle: .alert)
        /// Create an action to get back Home
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) {
            UIAlertAction in
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewControllerId") as! ViewController
            self.present(nextViewController, animated:true, completion:nil)
        }
        
        alert.addAction(tryAgainAction)
        self.present(alert, animated: true, completion: {
        })
        
    }
    
}

