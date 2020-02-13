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
    
    var user:User?
    let cellId = "cellId"
    var posts = [Post]()
    let refreshControl = UIRefreshControl()
    
    let loadingPhotosQueue = OperationQueue()
    var loadingPhotosOperations: [IndexPath: DataPrefetchOperation] = [:]
    
    // paginations properties
    var fetchingMore = false
    var endReached = false
    let leadingScreenForBatching:CGFloat = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.prefetchDataSource = self
        collectionView?.backgroundColor = .systemBackground
        collectionView?.register(HomePostCell.self,
                                 forCellWithReuseIdentifier: cellId)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleUpdateFeed),
                                               name: SharePhotoController.updateFeedNotificationName,
                                               object: nil)
        refreshControl.addTarget(self,
                                 action: #selector(refresh),
                                 for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        setupDMbarbuttomItem()
        setupNavigationItems()
        fetchUser()
        beginBatchFetch()
    }
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            //self.navigationItem.title = self.user?.username
        }
    }
    
    private func setupDMbarbuttomItem () {
        let button = UIBarButtonItem(image: UIImage(systemName: "paperplane")?.withTintColor(.label, renderingMode: .alwaysOriginal),
                                     style: .plain,
                                     target: self,
                                     action: #selector(showDMController))
        self.navigationItem.rightBarButtonItem = button
    }
    
    @objc
    private func showDMController() {
        guard let user = self.user else { return }
        let DMTVC = DMtableViewController()
        DMTVC.user = user
        DMTVC.navigationItem.title = "Direct"
        DMTVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(DMTVC, animated: true)
    }
    
    
    private var startKey:String?
    
    private func fetchFeedPosts(completion: @escaping (_ posts:[Post])->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let postsRef = Database.database().reference().child("FeedPosts").child(uid)
        
        
        var queryRef:DatabaseQuery
        if startKey == nil {
            queryRef = postsRef.queryOrderedByKey().queryLimited(toFirst: 3)
        } else {
            queryRef = postsRef.queryOrderedByKey().queryStarting(atValue: startKey).queryLimited(toFirst: 3)
        }
        
        queryRef.observeSingleEvent(of: .value) { snapshot in
            var newPosts = [Post]()
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                if self.startKey != key {
                    guard let dictionary = value as? [String: Any] else { return }
                    guard let userDic = dictionary["user"] as? [String: Any] else { return }
                    let user = User(uid: userDic["userId"] as! String, dictionary: userDic)
                    var post = Post(user: user, dictionary: dictionary)
                    post.id = key
                    newPosts.append(post)
                }
            })
            newPosts.sort { (p1, p2) -> Bool in
                let date1 = Double(p1.creationDate.timeIntervalSince1970)
                let date2 = Double(p2.creationDate.timeIntervalSince1970)
                return date1 < date2
            }
            let lastSnapshot = snapshot.children.allObjects.last as! DataSnapshot
            self.startKey = lastSnapshot.key
            completion(newPosts)
        }
    }
    
    @objc func handleUpdateFeed() {
        refresh()
    }

    @objc func refresh() {
        print("refresh...")
        //posts.removeAll()
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    
    func setupNavigationItems() {
        let image = #imageLiteral(resourceName: "logo")
        let tintImage = image.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: tintImage)
        imageView.tintColor = .label
        navigationItem.titleView = imageView
    }
    
    
    // MARK:- ScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        //print("\(offsetY): \(contentHeight)")
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreenForBatching {
            if !fetchingMore && !endReached {
                beginBatchFetch()
            }
        }
        print(posts.count)
    }
    
    private func beginBatchFetch() {
        fetchingMore = true
        fetchFeedPosts() { newPosts in
            self.posts.append(contentsOf: newPosts)
            self.endReached = newPosts.count == 0
            print(self.posts.count)
            self.fetchingMore = false
            self.collectionView.reloadData()
        }
    }

}

// MARK:- UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let commentString = posts[indexPath.item].caption
        let estimateHeight = commentString.getEdtimatedHeight(width: view.frame.width)
        var height: CGFloat = 40 + 8 + 8 //username and userProfileImageView
        height += view.frame.width
        height += 50
        height += 60
        height += estimateHeight
        return CGSize(width: view.frame.width, height: height)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId,
                                                      for: indexPath) as! HomePostCell
        if !self.refreshControl.isRefreshing {
            cell.post = posts[indexPath.item]
            
            // TODO: what if operation queue and customImage.load doesn't fetch => we left with two request!
            
        }
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
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

        // update like db
        let values = [uid: post.hasLiked ? 0 : 1]
        
        Database.database().reference().child("likes").child(postId).updateChildValues(values)
        { (err, _) in

            if let err = err {
                print("Failed to like post:", err)
                return
            }

            print("Successfully liked post")

            post.hasLiked = !post.hasLiked
            
            DispatchQueue.main.async {
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
            }
            
        }
        // update post
        Database.database().reference().child("FeedPosts").child(uid).child(postId).updateChildValues(["hasLiked": post.hasLiked ? false: true])
    }

}


// MARK:- UICollectionViewDataSourcePrefetching

extension HomeController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
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
    func collectionView(_ collectionView: UICollectionView,
                        cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataPrefetcher = loadingPhotosOperations[indexPath] {
                dataPrefetcher.cancel()
                loadingPhotosOperations.removeValue(forKey: indexPath)
                //print("cancel loading indexpath: \(indexPath)")
            }
        }
    }
}

