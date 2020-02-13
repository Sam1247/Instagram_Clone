//
//  UserProfileController.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/24/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit
import Firebase


class UserProfileController: UICollectionViewController {
    
    var user: User?
    var posts = [Post]()
    var userId: String?
    
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    
    var isGridView: Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .systemBackground
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        setupLogOutButton()
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.database().reference().child("users").child(uid).observe( .value) { snapshot in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            self.fetchOrderedPosts()
        }
        
//        Database.fetchUserWithUID(uid: uid) { (user) in
//            self.user = user
//            self.navigationItem.title = self.user?.username
//            self.collectionView?.reloadData()
//            self.fetchOrderedPosts()
//        }
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let user = self.user else { return }
            let post = Post(user: user, dictionary: dictionary)
            self.posts.insert(post, at: 0)
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to fetch ordered posts:", err)
        }
    }

        
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.dash")?.withTintColor(.label, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }

    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    weak var userProfileHeader: UserProfileHeader?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        self.userProfileHeader = header
        header.user = self.user
        header.delegate = self
        return header
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let bioString = user?.bio ?? ""
        let estimatedHeight = bioString.getEdtimatedHeight(width: view.frame.width)
        return CGSize(width: view.frame.width, height: 220 + estimatedHeight + 10)
    }
    
    
}

extension UserProfileController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8
            height += view.frame.width
            height += 50
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }
    }
}

extension UserProfileController: UserProfileHeaderDelegate {
    
    func setupHeaderEditFollowButton(for header: UserProfileHeader) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            //edit
            header.editProfileFollowButton.setTitle("Edit Profile", for: .normal)
        } else {
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    header.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                } else {
                    header.setupFollowStyle()
                }
            }) { (err) in
                print("Failed to check if following:", err)
            }
        }
    }
    
    
    func didTapFollowUnFollowButton() {
        //print("pressed!")
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        guard userId != currentLoggedInUserId else { return }
        
        if self.userProfileHeader?.editProfileFollowButton.titleLabel?.text == "Unfollow" {
            // unfollow
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    return
                }
                self.user!.followersCount -= 1
                // update users data
                Database.database().reference().child("users").child(userId).updateChildValues(["followersCount": self.user!.followersCount])
                
                //
                Database.fetchUserWithUID(uid: currentLoggedInUserId) { user in
                    Database.database().reference().child("users").child(currentLoggedInUserId).updateChildValues(["followingCount": user.followingCount-1])
                }
            }
            // update followers list
        Database.database().reference().child("followers").child(userId).child(currentLoggedInUserId).removeValue()
        } else {
            // follow
            // update following list
            let followingRef = Database.database().reference().child("following").child(currentLoggedInUserId)
            let values = [userId: 1]
            followingRef.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user:", err)
                    return
                }
                self.user!.followersCount += 1
                // update users data
                Database.database().reference().child("users").child(userId).updateChildValues(["followersCount": self.user!.followersCount])
                //
                Database.fetchUserWithUID(uid: currentLoggedInUserId) { user in
                    Database.database().reference().child("users").child(currentLoggedInUserId).updateChildValues(["followingCount": user.followingCount+1])
                }
            }
            // update followers list
            let followersRef = Database.database().reference().child("followers").child(userId)
            followersRef.updateChildValues([currentLoggedInUserId: 1])

        }
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }

     func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    
}

