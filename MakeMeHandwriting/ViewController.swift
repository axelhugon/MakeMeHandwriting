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
class ViewController: UIViewController, ValidationDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate{
    
    /// Validator to validate user inputs
    private let validator = Validator()
    private var fontDataSource = Array<Font>()
    private var fontImageDataSource = Array<UIImage>()
    private var selectedFontId: String = ""
    private var selectedColor: String = "#000000"
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
    /// Picker View to chose the font
    @IBOutlet var fontPickerView: UIPickerView!
    /// Color Buttons
    @IBOutlet var blackButton: UIButton!
    @IBOutlet var blueButton: UIButton!
    @IBOutlet var redButton: UIButton!
    @IBOutlet var greenButton: UIButton!
    
    // Constraints
    /// bottom generate button constraint
    @IBOutlet var buttonBottomConstraint: NSLayoutConstraint!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the most rated font (simulated, take the first 20)
        self.initPickerFont()
        
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

    
    
    /// When keyboard will open
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.buttonBottomConstraint.constant == 0{
                self.buttonBottomConstraint.constant += keyboardSize.height
            }
        }
        
    }
    
    //When the keyboard will close
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.buttonBottomConstraint.constant != 0{
                self.buttonBottomConstraint.constant -= keyboardSize.height
            }
        }
    }
    
    /// Init Gesture to close the heyboard
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    /// Close the Keyboard
    func dismissKeyboard()
    {
        view.endEditing(true)
    }

    
    
    // MARK: UIPickerViewDataSource & UIPickerViewDelegate
    
    /// Used to display the font name style with its own font
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let _fontImage = self.fontImageDataSource[row]
        
        let fontImageView = UIImageView(image: _fontImage)
        
        return fontImageView
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.fontImageDataSource.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let _font = self.fontDataSource[row]
        
        // When a font is selected, keep its id as selected
        self.selectedFontId = _font.id
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    
    // MARK : Color
    
    @IBAction func userChooseBlack(_ sender: UIButton) {
        colorSelected(sender, "#000000")
    }
    
    @IBAction func userChooseBlue(_ sender: UIButton) {
        colorSelected(sender, "#1E7FCB")
    }
    
    @IBAction func userChooseRed(_ sender: UIButton) {
        colorSelected(sender, "#FF0000")
    }
    
    @IBAction func userChooseGreen(_ sender: UIButton) {
        colorSelected(sender, "#60B732")
    }
    
    
    /// highlight the button selected and save the code color
    private func colorSelected(_ buttonTouched : UIButton, _ colorCode : NSString){
        
        blackButton.alpha = 0.5
        blueButton.alpha = 0.5
        redButton.alpha = 0.5
        greenButton.alpha = 0.5
        
        buttonTouched.alpha = 1.0
        
        self.selectedColor = colorCode as String
        
    }

    
    
    // MARK: Init
    
    private func initPickerFont() {
        self.fontPickerView.delegate = self
        self.fontPickerView.dataSource = self
        
        // All fields are validated, call the API to transform the user's input text into a handwrited text
        FontManager.sharedInstance.getHandwritings(20, offset: 0) { (fontList: Array<Font>?, error: FontError?) in
            guard error == nil else {
                // An error occured display an error message
                self.handleErrorFont(error: error!)
                return
            }
            
            guard fontList != nil else {
                // If the render object is nil, An error occured display an error message
                self.showErrorAlert(errorMessage: "An error occured")
                return
            }
            
            // Set the Data source
            self.fontDataSource = fontList!
            
            // Set the selected font as the first one
            if let firstFont = fontList?.first {
                self.selectedFontId = firstFont.id
            }
            
            for _font in fontList! {
                self.getFontNameStyleByItsOwnFont(font: _font)
            }
        }
        
    }
    
    
    private func getFontNameStyleByItsOwnFont(font: Font) {
        // All fields are validated, call the API to transform the user's input text into a handwrited text
        HandwriteTextManager.sharedInstance.getRenderText(font.title, fontId: font.id, color: "#000000", fontSize: "20px", height: "30px", width: "\(self.fontPickerView.frame.width)px") { (renderObject: Render?, error: HandwriteError?) in
            guard error == nil else {
                // An error occured display an error message
                self.handleError(error!)
                return
            }
            
            guard renderObject != nil else {
                // If the render object is nil, An error occured display an error message
                self.showErrorAlert(errorMessage: "An error occured")
                
                return
            }
            
            // Display the generated result image
            self.fontImageDataSource.append(renderObject!.handwritedTextImage)
            
            // Refresh the font picker
            self.fontPickerView.reloadAllComponents()
        }
        
    }
    
    
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
        // to hide Keyboard in touching anywhere
        self.hideKeyboard()
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
        // and pass parameters
        /// Send text without accent
        nextViewController.setTypedText(typedText: inputTextView.text.folding(options: .diacriticInsensitive, locale: .current) as NSString!)
        nextViewController.setFontId(fontId: self.selectedFontId as NSString!)
        nextViewController.setColor(color: self.selectedColor as NSString!)
        self.present(nextViewController, animated:true, completion:nil)

    }
    
    /// Trigger if the ValidationDelegate's `validation` failed.
    /// It will display all the error at the screen
    /// - parameters:
    ///   - errors: An array of all errors got by the `validate` step.
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        // Default error message
        var errorMessage: String = "An error occured."
        
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
    
    
    /// Display an error message according to its type
    /// - parameters:
    ///   - error: The error to handle
    private func handleErrorFont(error: FontError) {
        var errorMessage = "An error occured"
        
        switch error {
        case .rateLimitExceededError:
            errorMessage = "Rate Limit Exceeded"
            break
        default:
            errorMessage = "An error occured"
        }
        
        self.showErrorAlert(errorMessage: errorMessage)
    }
    
    
    

}

