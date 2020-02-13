//
//  CommentInputTextView.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 1/25/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {

    fileprivate let placeholderLabel: UILabel = {
        let label = UILabel()
        //label.text = "Enter Comment"
        label.textColor = UIColor.lightGray
        return label
    }()

    func showPlaceHolderLabel() {
        placeholderLabel.isHidden = false
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        backgroundColor = .tertiarySystemBackground
        //NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name:  , object: nil)
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
   }

    @objc func handleTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }

}
