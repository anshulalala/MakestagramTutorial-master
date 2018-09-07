//
//  PostHeaderCell.swift
//  Makestagram
//
//  Created by Brian Sakhuja on 6/28/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet weak var usernameLabel: UILabel!
    
    static let height: CGFloat = 54
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - IBAction
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        print("options button tapped")
    }
}
