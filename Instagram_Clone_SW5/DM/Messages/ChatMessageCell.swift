//
//  ChatMessageCell.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 2/8/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import UIKit

class BaseChatMessageCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            messageLabel.text = message?.text
        }
    }
    
    let bubbleBackgroundView = UIView()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
//    var isComing:Bool! {
//        didSet {
//            self.setupConstraints()
//        }
//    }
    
//    let profileImageView: CustomImageView = {
//        let iv = CustomImageView()
//        iv.clipsToBounds = true
//        iv.contentMode = .scaleAspectFill
//        //iv.backgroundColor = .blue
//        return iv
//    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private func sharedInit() {
//        backgroundColor = .clear
//        addSubview(bubbleBackgroundView)
//        addSubview(messageLabel)
//        addSubview(profileImageView)
//        bubbleBackgroundView.layer.cornerRadius = 12
//        profileImageView.layer.cornerRadius = 36/2
//        setupConstraints()
//    }
    
    
    override func layoutSubviews() {
        setupConstraints()
    }
    
    func setupConstraints() {
        
//        backgroundColor = .clear
//        addSubview(bubbleBackgroundView)
//        addSubview(messageLabel)
//        addSubview(profileImageView)
//        bubbleBackgroundView.layer.cornerRadius = 12
//        profileImageView.layer.cornerRadius = 36/2
//        if true {
//            messageLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 16, paddingLeft: 32 + 24, paddingBottom: 16, paddingRight: 0, width: 0, height: 0)
//            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
//            bubbleBackgroundView.anchor(top: messageLabel.topAnchor, left: messageLabel.leftAnchor, bottom: messageLabel.bottomAnchor, right: messageLabel.rightAnchor, paddingTop: -8, paddingLeft: -8, paddingBottom: -8, paddingRight: -8, width: 0, height: 0)
//
//            profileImageView.anchor(top: nil, left: nil, bottom: bubbleBackgroundView.bottomAnchor, right: bubbleBackgroundView.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 6, width: 36, height: 36)
//            bubbleBackgroundView.backgroundColor = .tertiarySystemBackground
//        } else {
//            messageLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 16, paddingRight: 32 , width: 0, height: 0)
//            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
//
//            bubbleBackgroundView.anchor(top: messageLabel.topAnchor, left: messageLabel.leftAnchor, bottom: messageLabel.bottomAnchor, right: messageLabel.rightAnchor, paddingTop: -8, paddingLeft: -8, paddingBottom: -8, paddingRight: -8, width: 0, height: 0)
//            //profileImageView.anchor(top: nil, left: bubbleBackgroundView.rightAnchor, bottom: bubbleBackgroundView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 6, paddingBottom: 0, paddingRight: 0, width: 36, height: 36)
//             bubbleBackgroundView.backgroundColor = .systemBlue
//        }
    }
    
}


class GoingChatMessageCell: BaseChatMessageCell {
    
    override func setupConstraints() {
        backgroundColor = .clear
        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)
        bubbleBackgroundView.layer.cornerRadius = 12
        messageLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 16, paddingRight: 32 , width: 0, height: 0)
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true

        bubbleBackgroundView.anchor(top: messageLabel.topAnchor, left: messageLabel.leftAnchor, bottom: messageLabel.bottomAnchor, right: messageLabel.rightAnchor, paddingTop: -8, paddingLeft: -8, paddingBottom: -8, paddingRight: -8, width: 0, height: 0)
        //profileImageView.anchor(top: nil, left: bubbleBackgroundView.rightAnchor, bottom: bubbleBackgroundView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 6, paddingBottom: 0, paddingRight: 0, width: 36, height: 36)
         bubbleBackgroundView.backgroundColor = .systemBlue
    }
}


class CommingChatMessageCell: BaseChatMessageCell {
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        //iv.backgroundColor = .blue
        return iv
    }()
    
    override func setupConstraints() {
        backgroundColor = .clear
        addSubview(bubbleBackgroundView)
        addSubview(messageLabel)
        addSubview(profileImageView)
        bubbleBackgroundView.layer.cornerRadius = 12
        profileImageView.layer.cornerRadius = 36/2
        messageLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 16, paddingLeft: 32 + 24, paddingBottom: 16, paddingRight: 0, width: 0, height: 0)
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        bubbleBackgroundView.anchor(top: messageLabel.topAnchor, left: messageLabel.leftAnchor, bottom: messageLabel.bottomAnchor, right: messageLabel.rightAnchor, paddingTop: -8, paddingLeft: -8, paddingBottom: -8, paddingRight: -8, width: 0, height: 0)
        
        profileImageView.anchor(top: nil, left: nil, bottom: bubbleBackgroundView.bottomAnchor, right: bubbleBackgroundView.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 6, width: 36, height: 36)
        bubbleBackgroundView.backgroundColor = .tertiarySystemBackground
    }
}
