//
//  ViewController.swift
//  MakeMeHandwriting
//
//  Created by Axel Hugon on 09/01/2017.
//  Copyright © 2017 AHUGON. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //Objects from the Storyboard
    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var generateButton: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var containerScrollView: UIScrollView!
    
    //Constraints
    @IBOutlet var buttonBottomConstraint: NSLayoutConstraint!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.buttonBottomConstraint.constant == 0{
                self.buttonBottomConstraint.constant += keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.buttonBottomConstraint.constant != 0{
                self.buttonBottomConstraint.constant -= keyboardSize.height
            }
        }
    }
    

    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.buttonBottomConstraint.constant = keyboardFrame.size.height + 20
        })
    }

}

