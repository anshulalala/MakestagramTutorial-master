//
//  StorageService.swift
//  Makestagram
//
//  Created by Brian Sakhuja on 6/27/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class StorageService {
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // change the image from an UIImage to Data and reduce the quality of the image.  If we can't convert the image into Data, we return nil to the completion callback to signal something went wrong.
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // upload our media data to the path provided as a parameter to the method.
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // After the upload completes, we check if there was an error. If there is an error, we return nil to our completion closure to signal there was an error. Our assertFailure will crash the app and print the error when we're running in debug mode.
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            // If everything was successful, we return the download URL for the image.
            completion(metadata?.downloadURL())
        })
    }
}
