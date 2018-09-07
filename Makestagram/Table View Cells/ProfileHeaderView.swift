//
//  ProfileHeaderView.swift
//  Makestagram
//
//  Created by Brian Sakhuja on 7/1/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

protocol ProfileHeaderViewDelegate: class {
    func didTapSettingsButton(_ button: UIButton, on headerView: ProfileHeaderView)
}

class ProfileHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    weak var delegate: ProfileHeaderViewDelegate?
    
    // MARK: - Subviews
    
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        settingsButton.layer.cornerRadius = 6
        settingsButton.layer.borderColor = UIColor.lightGray.cgColor
        settingsButton.layer.borderWidth = 1
    }
    
    // MARK: - IBActions
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        delegate?.didTapSettingsButton(sender, on: self)
    }
    
    
    
}
