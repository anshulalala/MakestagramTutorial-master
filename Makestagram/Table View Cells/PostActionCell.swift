//
//  PostActionCell.swift
//  Makestagram
//
//  Created by Brian Sakhuja on 6/28/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import UIKit

protocol PostActionCellDelegate: class {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell)
    
}


class PostActionCell: UITableViewCell {
    
    // MARK: - Subviews
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    // MARK: - Properties
    weak var delegate: PostActionCellDelegate?
    
    static let height: CGFloat = 46
    

    // MARK: - Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - IBActions
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(sender, on: self)
    }
    
    
}
