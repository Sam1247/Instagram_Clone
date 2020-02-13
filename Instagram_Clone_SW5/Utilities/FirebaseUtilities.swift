//
//  FirebaseUtilities.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/25/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import Foundation
import Firebase

extension Auth {

    func createUser(with email: String,
                    username: String,
                    password: String,
                    bio: String, image: UIImage?,
                    completion: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, err: Error?) in
            if let err = err { completion(err); return }

            Storage.storage().uploadUserProfileImage(image: image, completion: { (profileImageUrl, err) in
                if let err = err { completion(err); return }
                guard let uid = user?.user.uid else { return }
                Database.database().uploadUser(withUID: uid,
                                               username: username,
                                               profileImageUrl: profileImageUrl,
                                               bio: bio,
                                               completion:
                    { (err) in
                    if let err = err { completion(err); return }
                        completion(nil)
                })
            })
        })
    }
    
    

}

extension Storage {
    
    fileprivate func uploadUserProfileImage(image: UIImage?, completion: @escaping (String?, Error?) -> ()) {
        guard let image = image else { completion(nil, nil); return }
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child(filename)
        
        storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
            if let err = err { completion(nil, err); return }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err { completion(nil, err); return }
                
                guard let profileImageUrl = downloadURL?.absoluteString else { return }
                completion(profileImageUrl, nil)
            })
        })
    }
    
}



extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (err) in
            print("Failed to fetch user for posts: ", err)
        }
    }
    
    fileprivate func uploadUser(withUID uid: String,
                                username: String,
                                profileImageUrl: String? = nil,
                                bio: String,
                                completion: @escaping (Error?) -> () ) {
        var dictionaryValues:[String:Any] = ["username": username, "bio": bio]
        if profileImageUrl != nil {
            dictionaryValues["profileImageUrl"] = profileImageUrl
        }
        dictionaryValues["followingCount"] = 0
        dictionaryValues["followersCount"] = 0
        dictionaryValues["postsCount"] = 0
        
        let values = [uid: dictionaryValues]
        Database.database().reference().child("users").updateChildValues(values,
                                                                         withCompletionBlock: { (err, ref) in
            if let err = err { completion(err); return }
            completion(nil)
        })
    }
    
}

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
}



protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}
