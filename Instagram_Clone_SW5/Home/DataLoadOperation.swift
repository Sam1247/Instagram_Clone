//
//  DataLoadOperation.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 1/26/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import Foundation
import UIKit

class DataPrefetchOperation: Operation {

    let imageUrl: String
    
    init(with url:String) {
        self.imageUrl = url
    }
    
    override func main() {
        if isCancelled { return }
            // fire a download
        ImageFetcherHelper.loadImage(with: self.imageUrl)
    }
}
