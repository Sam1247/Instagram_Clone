//
//  HomeController.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/25/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, HomePostCellDelegate {
    
    
    let cellId = "cellId"
    var posts = [Post]()
    let refreshControl = UIRefreshControl()
    
    let loadingPhotosQueue = OperationQueue()
    var loadingPhotosOperations: [IndexPath: DataPrefetchOperation] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.prefetchDataSource = self
        collectionView?.backgroundColor = .systemBackground
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        setupDMbarbuttomItem()
        setupNavigationItems()
        posts.removeAll()
        fetchAllPosts()
    }
    
    private func setupDMbarbuttomItem () {
        let button = UIBarButtonItem(image: UIImage(systemName: "paperplane")?.withTintColor(.label, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(showDMController))
        self.navigationItem.rightBarButtonItem = button
    }
    
    @objc
    private func showDMController() {
        let DMTVC = DMtableViewController()
        DMTVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(DMTVC, animated: true)
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingPosts()
    }
    
    @objc func handleUpdateFeed() {
        refresh()
    }

    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchFollowingPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
         Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
             guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
             userIdsDictionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })

         }) { (err) in
            print("Failed to fetch followung user ids:", err)
        }
    }
    
    @objc func refresh() {
        print("refresh...")
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.collectionView?.refreshControl?.endRefreshing()
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.database().reference().child("likes").child(key).child(uid).observe(.value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    self.posts.append(post)
                }, withCancel: { (err) in
                    print("Failed to fetch like info for post:", err)
                })
            })
            self.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
    }
    
    func setupNavigationItems() {
        let image = #imageLiteral(resourceName: "logo")
        let tintImage = image.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: tintImage)
        imageView.tintColor = .label
        navigationItem.titleView = imageView
    }

}

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let commentString = posts[indexPath.item].caption
        let estimateHeight = commentString.getEdtimatedHeight(width: view.frame.width)
        var height: CGFloat = 40 + 8 + 8 //username and userProfileImageView
        height += view.frame.width
        height += 50
        height += 60
        height += estimateHeight
        return CGSize(width: view.frame.width, height: height)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        if !self.refreshControl.isRefreshing {
            cell.post = posts[indexPath.item]
            
            // TODO: what if operation queue and customImage.load doesn't fetch => we left with two request!
            
        }
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dataLoader = loadingPhotosOperations[indexPath] {
            loadingPhotosOperations.removeValue(forKey: indexPath)
            dataLoader.cancel()
        }
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        commentsController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }

        var post = posts[indexPath.item]

        guard let postId = post.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }


        let values = [uid: post.hasLiked ? 0 : 1]
        
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, _) in

            if let err = err {
                print("Failed to like post:", err)
                return
            }

            print("Successfully liked post")

            post.hasLiked = !post.hasLiked
            
            // structs man! xD
            DispatchQueue.main.async {
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
            }
            
        }
    }

}


extension HomeController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if !self.refreshControl.isRefreshing {
            for indexPath in indexPaths {
                let imageUrl = posts[indexPath.row].imageUrl
                if imageCache[imageUrl] == nil {
                    //print("loading indexpath: \(indexPath)")
                    let dataPrefetcher = DataPrefetchOperation(with: imageUrl)
                    loadingPhotosQueue.addOperation(dataPrefetcher)
                    loadingPhotosOperations[indexPath] = dataPrefetcher
                }
            }
        }
    }
    
    // it's only called when the cache is cleared as the photos
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataPrefetcher = loadingPhotosOperations[indexPath] {
                dataPrefetcher.cancel()
                loadingPhotosOperations.removeValue(forKey: indexPath)
                //print("cancel loading indexpath: \(indexPath)")
            }
        }
    }
}
