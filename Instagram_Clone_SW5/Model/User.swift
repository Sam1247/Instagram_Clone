//
//  User.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/24/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    let bio: String
    var followingCount: Int
    var followersCount: Int
    var postsCount: Int

    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        username = dictionary["username"] as? String ?? ""
        profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        bio = dictionary["bio"] as? String ?? ""
        followingCount = dictionary["followingCount"] as? Int ?? 0
        followersCount = dictionary["followersCount"] as? Int ?? 0
        postsCount = dictionary["postsCount"] as? Int ?? 0
    }

}
