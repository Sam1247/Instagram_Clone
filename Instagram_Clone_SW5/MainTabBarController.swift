//
//  MainTabBarController.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/24/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let redVC = UIViewController()
        redVC.view.backgroundColor = .red

        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)

        let navController = UINavigationController(rootViewController: userProfileController)

        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")

        tabBar.tintColor = .black

        viewControllers = [navController, UIViewController()]
    }
    

    

}
