//
//  Render.swift
//  MakeMeHandwriting
//
//  Created by Axel Hugon on 09/01/2017.
//  Copyright © 2017 AHUGON. All rights reserved.
//

import Foundation
import UIKit


/// A Model representing a Handwrited Text.
///
/// The handwrited text is a PNG image
class Render {
    
    /// The image representing the handwrited text
    var handwritedTextImage: UIImage!
    
    /// Initialize a new Model with the data of the handwrited text image
    ///
    /// - parameters:
    ///   - imageData: the data representing the handwrited text image.
    required init(imageData: Data) {
        self.handwritedTextImage = UIImage(data: imageData, scale: 1.0)!
    }
    
}

