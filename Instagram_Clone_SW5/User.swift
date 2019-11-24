//
//  User.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/24/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import Foundation

struct User {
    let username: String
    let profileImageUrl: String

    init(dictionary: [String: Any]) {
        username = dictionary["username"] as? String ?? ""
        profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }

}
