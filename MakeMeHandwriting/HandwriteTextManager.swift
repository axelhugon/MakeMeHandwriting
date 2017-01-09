//
//  HandwriteTextManager.swift
//  MakeMeHandwriting
//
//  Created by Axel Hugon on 09/01/2017.
//  Copyright © 2017 AHUGON. All rights reserved.
//

import Foundation
import Alamofire

/// This represent an error in the process of rendering a handwriting text.
/// The error could be:
/// - `RateLimitExceededError` for rate limit exceeded
/// - `HWUnsupportedCharacterError` for unsupported character
/// - `GenericError` for any other king of error
enum HandwriteError : Error {
    case genericError
    case rateLimitExceededError
    case hwUnsupportedCharacterError
}

/// This is a type used by the call to render a handwrited text. This is composed of a `HWRender` type if the operation succeed, and of a `HandwriteError` in case of error
typealias ServiceResponseRender = (Render?, HandwriteError?) -> Void

/// A class handling the API calls to render a handwrited text
class HandwriteTextManager: NSObject {
    
    /// Singleton
    static let sharedInstance = HandwriteTextManager()
    
    
    /// Endpoint to render a handwrited text to a PNG image
    let RENDER_PNG_ENDPOINT = "/render/png"
    
    
    /// Render an input text to a handwrited text as a PNG Image
    ///
    /// - parameters:
    ///   - text: the text to transform into a handwrited text image.
    ///   - onCompletion: a completion callback to handle the success or error result
    func getRenderText(_ text: String, fontId: String, color: String, fontSize: String, height: String, width: String = "auto", onCompletion: @escaping ServiceResponseRender) {
        // Define the URL endpoint
        let requestUrl = HWConfig.HANDWRITING_API_URL + RENDER_PNG_ENDPOINT
        
        // Build the array of parameters
        let params = [
            "handwriting_id" : fontId,
            "text": text,
            "handwriting_size": fontSize, // 0px - 9000px
            "handwriting_color": color,
            "height": height,
            "width": width,
            ]
        
        // Automatically validates status code within 200...299 range, and that the Content-Type header of the response matches the Accept header of the request
        Alamofire.request(requestUrl, method: .get, parameters: params, encoding: URLEncoding.default, headers: self.getHTTPHeaderForAuthorization())
            .validate() // Test the response is between 200 and 299
            .responseData { response in
                
                // If success, execute onCompletion callback with a Render Model
                // If failed, execute onCompletion callback with an HandwriteError error
                switch response.result {
                case .success:
                    if (response.data != nil) {
                        // Create model to return
                        onCompletion(Render(imageData: response.data!), nil)
                    } else {
                        onCompletion(nil, HandwriteError.genericError)
                    }
                case .failure:
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 400:
                            onCompletion(nil, HandwriteError.hwUnsupportedCharacterError)
                        case 429:
                            onCompletion(nil, HandwriteError.rateLimitExceededError)
                        default : onCompletion(nil, HandwriteError.genericError)
                        }
                    }
                }
            }
    }
    
    /// Get the HTTP header required to call the Handwriting.io API
    ///
    /// - returns: An array of key-value for each header, containing the Authorization HTTP Header.
    fileprivate func getHTTPHeaderForAuthorization() -> [String: String] {
        let loginString = NSString(format: "%@:%@", HWConfig.HANDWRITING_API_KEY, HWConfig.HANDWRITING_API_SECRET)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        
        let headers = [
            "Authorization": "Basic \(base64LoginString)"
        ]
        
        return headers
    }

}

