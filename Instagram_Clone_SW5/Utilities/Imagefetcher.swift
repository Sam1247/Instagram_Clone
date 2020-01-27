//
//  Imagefetcher.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 1/27/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import Foundation
import UIKit

struct ImageFetcherHelper {
    static func loadImage(with url: String) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
        }.resume()
    }
}
