//
//  HomePostCell.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/25/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        //label.backgroundColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()

    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
        performLikeAnimation()
    }
    
    private func performLikeAnimation() {
        if likeButton.imageView?.image == UIImage(systemName: "heart") {
            likeButton.setImage(UIImage(systemName: "heart")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "heart.fill")!.withTintColor(.systemRed, renderingMode: .alwaysOriginal), for: .normal)
        }
        //likeButton.setImage(post?.hasLiked == true ? UIImage(systemName: "heart.fill")!.withTintColor(.systemRed, renderingMode: .alwaysOriginal) : UIImage(systemName: "heart")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: [], animations: {
            self.animatedLikeImageView.transform = .identity
            self.animatedLikeImageView.alpha = 1
        }) { (bool) in
            self.animatedLikeImageView.transform = .init(scaleX: 0.1, y: 0.1)
            self.animatedLikeImageView.alpha = 0
        }
    }

    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message")?.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    @objc func handleComment() {
        guard let post = post else { return }
        delegate?.didTapComment(post: post)
    }

    let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()

    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()

    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let animatedLikeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        //iv.backgroundColor = .systemRed
        return iv
    }()
    
    var post: Post? {
        didSet {
            guard let postImageUrl = post?.imageUrl else { return }
            likeButton.setImage(post?.hasLiked == true ? UIImage(systemName: "heart.fill")!.withTintColor(.systemRed, renderingMode: .alwaysOriginal) : UIImage(systemName: "heart")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
            photoImageView.loadImage(urlString: postImageUrl)
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            usernameLabel.text = post!.user.username
            userProfileImageView.loadImage(urlString: profileImageUrl)
            setupAttributedCaption()
        }
    }
    
    
    
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))

        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: post.creationDate.displayTimeAgo(), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))

        captionLabel.attributedText = attributedText
    }

    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()


    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        backgroundColor = UIColor.systemBackground
        addSubview(photoImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(userProfileImageView)
        addSubview(animatedLikeImageView)

        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2

        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        optionsButton.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)

        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        setupActionButtons()

        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        animatedLikeImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 125)
        animatedLikeImageView.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
        animatedLikeImageView.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor).isActive = true
        animatedLikeImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        animatedLikeImageView.alpha = 0
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)

        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
    }
}
