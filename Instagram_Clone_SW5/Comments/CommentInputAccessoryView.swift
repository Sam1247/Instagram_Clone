//
//  CommentInputAccessoryView.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 1/25/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import UIKit

class CommentInputAccessoryView: UIView {

    var delegate: CommentInputAccessoryViewDelegate?

    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceHolderLabel()
    }

    fileprivate let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.layer.cornerRadius = 12
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()

    fileprivate let submitButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.setTitleColor(.systemBlue, for: .normal)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb
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
        backgroundColor = .systemBackground
        autoresizingMask = .flexibleHeight

        addSubview(submitButton)
        submitButton.anchor(top: nil, left: nil, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)

        addSubview(commentTextView)
        commentTextView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 12, width: 0, height: 0)

        //setupLineSeparatorView()
    }

    override var intrinsicContentSize: CGSize {
        return .zero
    }


    @objc func handleSubmit() {
        guard let commentText = commentTextView.text else { return }
        delegate?.didSubmit(for: commentText)
    }

}
