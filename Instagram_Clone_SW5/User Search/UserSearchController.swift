//
//  UserSearchController.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/25/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController {
    
    let cellId = "cellId"
    var filteredUsers = [User]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        navigationItem.titleView = searchBar
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        fetchUsers()
    }
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.barTintColor = .gray
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        sb.delegate = self
        return sb
    }()
   
    
    fileprivate func fetchUsers() {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
             guard let dictionaries = snapshot.value as? [String: Any] else { return }
             dictionaries.forEach({ (key, value) in
                 if key == Auth.auth().currentUser?.uid {
                    return
                }
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            })
            self.users.sort(by: { (user1, user2) -> Bool in
                return user1.username.compare(user2.username) == .orderedAscending
            })
            self.filteredUsers = self.users
            self.collectionView?.reloadData()
         }) { (err) in
            print("Failed to fetch users for search:", err)
        }
    }
}

extension UserSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView?.reloadData()
    }
}

extension UserSearchController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let user = filteredUsers[indexPath.item]
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
}


