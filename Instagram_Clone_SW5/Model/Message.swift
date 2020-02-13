//
//  Message.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 2/9/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import Foundation

import Foundation

struct Message {
    var fromId: String
    var text: String
    var toId: String
    var timeStamp: Double
    
    init(dictionary: [String: Any]) {
        fromId = dictionary["fromId"] as? String ?? ""
        text = dictionary["text"] as? String ?? ""
        toId = dictionary["toId"] as? String ?? ""
        timeStamp = dictionary["timeStamp"] as? Double ?? 0
    }
    
}

