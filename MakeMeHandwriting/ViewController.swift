//
//  ViewController.swift
//  MakeMeHandwriting
//
//  Created by Axel Hugon on 09/01/2017.
//  Copyright © 2017 AHUGON. All rights reserved.
//

import UIKit
import SwiftValidator // Validation System
import Alamofire

/// A ViewController responsible for handling the tranformation of an input text into a handwrited text
class ViewController: UIViewController, ValidationDelegate {
    
    /// Validator to validate user inputs
    fileprivate let validator = Validator()
    fileprivate var fontImageDataSource = Array<UIImage>()
    /// singleton : manager for reachability
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    
    
    // UI Objects
    /// The text to transform into a handwrited text
    @IBOutlet var inputTextView: UITextView!
    /// The button to process the transformation
    @IBOutlet var generateButton: UIButton!
    /// The view containing all ui objects
    @IBOutlet var containerView: UIView!
    /// The scroll view containing all views and ui objects
    @IBOutlet var containerScrollView: UIScrollView!
    
    // Constraints
    /// bottom generate button constraint
    @IBOutlet var buttonBottomConstraint: NSLayoutConstraint!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Validation
        self.initValidator()
        
        //Init Keyboard Actions
        self.initKeyboard()
        
        //Init Reachability Listener
        self.listenForReachability()
        
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
    
    // MARK: Init
    
    
    /// Initialize a validator to validate user's input
    fileprivate func initValidator() {
        // Build a chartset composed of letters (lower and upper, without accents), digits, punctuation and whitespace and new line
        let charset = NSMutableCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopq‌​rstuvwxyz")
        charset.formUnion(with: CharacterSet.whitespacesAndNewlines)
        charset.formUnion(with: CharacterSet.decimalDigits)
        charset.formUnion(with: CharacterSet.punctuationCharacters)
        
        
        // Register the text to transform field for its validation
        validator.registerField(inputTextView as ValidatableField, rules: [
            RequiredRule(message: "Please type a text to transform"),
            CharacterSetRule(characterSet: charset as CharacterSet, message: "Please type only alphanumeric characters"),
            MaxLengthRule(length: 9000, message: "The text must be at most 9000 characters long"),
            MinLengthRule(length: 1, message: "The text must be at least 1 character long")
            ]
        )
    }
    
    ///Initialize Observer on keyboard hide and unhide
    fileprivate func initKeyboard() {
        // on keyboard unhide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // on keyboard hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    
    // MARK: User Interaction
    

    /// Validate the user's input. If success, it triggers `validationSuccessful()`, otherwise `validationFailed()`
    ///
    /// - parameters:
    ///   - sender: the button that triggered the action.
    @IBAction func onGenerateAction(_ sender: Any) {
        
        // Test Reachability
        if (self.reachabilityManager?.isReachable)!{
            // Connection OK
            // Validate the field, if pass call API to transform text into handwrite text, otherwise, show an error message
            self.validator.validate(self)
        } else {
            // Connection KO
            self.showErrorAlert(errorMessage: "No internet connection. Please verify and try again.")
        }
        
    }
    
    // MARK: ValidationDelegate
    
    /// Trigger if the ValidationDelegate's `validation` succeed.
    /// It will redirect to the next view to call the API to get the user's input text as a handwrited text
    func validationSuccessful() {
        
        // Redirect to the next view
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoadingViewControllerId") as! LoadingViewController
        nextViewController.setTypedText(typedText: inputTextView.text as NSString!)
        self.present(nextViewController, animated:true, completion:nil)

    }
    
    /// Trigger if the ValidationDelegate's `validation` failed.
    /// It will display all the error at the screen
    /// - parameters:
    ///   - errors: An array of all errors got by the `validate` step.
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        // Default error message
        var errorMessage: String = "An error occured. Please fixed:"
        
        // Consolidate all errors found into 1 message
        for (_, error) in validator.errors {
            errorMessage += "\n" + error.errorMessage
        }
        
        // And display this consolidated error message
        self.showErrorAlert(errorMessage: errorMessage)
    }

    
    //MARK : Connection
    // Test Reachability Listener
    func listenForReachability() {
        self.reachabilityManager?.listener = { status in
            switch status {
            case .notReachable:
                // Connection KO
                self.showErrorAlert(errorMessage: "No internet connection. Please verify and try again.")
                break
            case .reachable(_), .unknown:
                // Connection OK
                break
            }
        }
        
        self.reachabilityManager?.startListening()
    }
    
    //MARK : Errors
    
    /// Show an alert with the error
    fileprivate func showErrorAlert( errorMessage : String ){
        
        /// Create an alert
        let alert = UIAlertController(title: "Oups", message: errorMessage, preferredStyle: .alert)
        /// Create an action
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion:nil)
        
    }
    
    
    /// Display an error message according to its type
    /// - parameters:
    ///   - error: The error to handle
    fileprivate func handleError(_ error: HandwriteError) {
        var errorMessage = "An error occured"
        
        switch error {
        case .hwUnsupportedCharacterError:
            errorMessage = "You entered an unsupported character, please try again"
            break
        case .rateLimitExceededError:
            errorMessage = "Rate Limit Exceeded"
            break
        default:
            errorMessage = "An error occured"
        }
        
        self.showErrorAlert(errorMessage: errorMessage)
    }
    
    
    

}

