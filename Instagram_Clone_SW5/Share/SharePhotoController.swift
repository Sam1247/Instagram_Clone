//
//  SharePhotoController.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/24/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {

    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(handleShare))
        setupViews()
    }
    
    // update HomeFeed
    static let updateFeedNotificationName = Notification.Name(rawValue: "UpdateFeed")
    
    @objc private func handleShare() {
        guard let caption = textView.text, !caption.isEmpty else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = image.jpegData(compressionQuality: 0.2) else { return }
        navigationItem.rightBarButtonItem?.isEnabled = false
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", err)
                return
            }
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to fetch downloadURL:", err)
                    return
                }
                guard let imageUrl = downloadURL?.absoluteString else { return }
                print("Successfully uploaded post image:", imageUrl)
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            })
        }
    }

    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        var values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB", err)
                return
            }
            print("Successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
        // update user profile info
        let userRef = Database.database().reference().child("users").child(uid)
        Database.fetchUserWithUID(uid: uid) { user in
            userRef.updateChildValues(["postsCount": user.postsCount+1])
        }
        // update feed posts
        let feedPostRefperUser = Database.database().reference().child("FeedPosts")
        let followersRef = Database.database().reference().child("followers").child(uid)
        followersRef.observeSingleEvent(of: .value) { snapshot in
             guard let dictionary = snapshot.value as? [String: Int] else { return }
            dictionary.forEach { (key, value) in
                
                //let userDic = [uid: ]
                //feedPostRefperUser.child(key).childByAutoId().updateChildValues(values)
                Database.fetchUserWithUID(uid: uid) { user in
                    let userDic:[String: Any] = ["userId": uid,
                                                 "bio ": user.bio,
                                                 "followersCount": user.followersCount,
                                                 "followingCount": user.followingCount,
                                                 "postsCount": user.postsCount,
                                                 "profileImageUrl": user.profileImageUrl,
                                                 "username": user.username
                                                ]
                    values["user"] = userDic
                    feedPostRefperUser.child(key).childByAutoId().updateChildValues(values)
                }
            }
            
        }
        
    }

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .secondarySystemBackground
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()

    private func setupViews() {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)

        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)

        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

}
