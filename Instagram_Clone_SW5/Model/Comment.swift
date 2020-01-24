//
//  Comment.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 1/24/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    let text: String
    let uid: String

    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
    
}
