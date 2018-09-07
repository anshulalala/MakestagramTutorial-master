//
//  UITableView+Utility.swift
//  Makestagram
//
//  Created by Brian Sakhuja on 6/30/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import UIKit

protocol CellIdentifiable {
    static var cellIdentifier: String { get }
}

// create an extension on our protocol CellIdentifiable. In our extension, we can define default values for our protocol properties and functions.
extension CellIdentifiable where Self: UITableViewCell  {
   // define a default value for cellIdentifier. We return the name of the custom UITableViewCell class as a string using String(describing:). This prevents us from making typos when typing out the cell identifier as a String.
    static var cellIdentifier: String {
        return String(describing: self)
    }
    
}

// make sure that UITableViewCell implements the CellIdentifiable protocol.
extension UITableViewCell: CellIdentifiable {
    
}

extension UITableView {
    // define a generic function that extensions UITableView.
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: CellIdentifiable {
        // unwrap the custom UITableViewCell based on it's cellIdentifier and make sure the type conforms to T. In this line, we remove the need to type out the cell identifier as a String and force casting the type explicitly
        guard let cell = dequeueReusableCell(withIdentifier: T.cellIdentifier) as? T else {
            // If the identifier or casting fails, we crash the app but print a nice error message so we'll know which cell caused the issue
            fatalError("Error dequeuing cell for identifier \(T.cellIdentifier)")
        }
        
        return cell
    }
}
