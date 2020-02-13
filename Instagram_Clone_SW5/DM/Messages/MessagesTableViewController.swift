//
//  MessagesTableViewController.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 2/8/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import UIKit
import Firebase

class MessagesTableViewController: UITableViewController, CommentInputAccessoryViewDelegate {
    
    var user: User?
    
    let cellIdComming  = "cellIdComming"
    let cellIdGoing  = "cellIdGoing"
    
    var messages = [Message]()
    
    var keyboardHeight = CGFloat.zero

    // paginations properties
    var fetchingMore = false
    var endReached = false
    let leadingScreenForBatching:CGFloat = 3
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.register(CommingChatMessageCell.self, forCellReuseIdentifier: cellIdComming)
        tableView.register(GoingChatMessageCell.self, forCellReuseIdentifier: cellIdGoing)
        //fetchMessages()
        setupNavBarWithUser()
        setupInvertedTable()
        tableView.keyboardDismissMode = .interactive
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustContentSizeIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObservingKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyboard()
    }
    
    private func adjustContentSizeIfNeeded() {
        var contentInset = tableView.contentInset

        contentInset.bottom = topHeight
        contentInset.top = bottomHeight

        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    var topHeight: CGFloat {
        if navigationController?.navigationBar.isTranslucent ?? false {
            var top = navigationController?.navigationBar.frame.height ?? 0.0
            top += UIApplication.shared.statusBarFrame.height
            return top
        }
        return 0.0
    }
    
    
    var bottomHeight: CGFloat {
        var composer = keyboardHeight > 0.0 ? (keyboardHeight + 70): containerView.frame.height - 25
        composer += view.safeAreaInsets.bottom
        return composer
    }
    
    private func setupInvertedTable() {
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    private var startKey:String?
    
    private func fetchMessages(completion: @escaping (_ Message:[Message])->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let idsSorted = [uid, user!.uid].sorted()
        let messagesRef = Database.database().reference().child("Direct/messages/\(idsSorted[0])/\(idsSorted[1])")
        
        var queryRef:DatabaseQuery
        
        if startKey == nil {
            queryRef = messagesRef.queryOrderedByKey().queryLimited(toLast: 16)
        } else {
            queryRef = messagesRef.queryOrderedByKey().queryEnding(atValue: startKey).queryLimited(toLast: 16)
        }
        
        queryRef.observeSingleEvent(of: .value) { snapshot in
            var newMessages = [Message]()
            guard let dictionaries = snapshot.value as? [String:Any] else { return }
            dictionaries.forEach { (arg) in
                if self.startKey != arg.key {
                    let dictionary = arg.value as! [String:Any]
                    let message = Message(dictionary: dictionary)
                    newMessages.append(message)
                }
            }
            newMessages.sort { (m1, m2) -> Bool in
                m1.timeStamp > m2.timeStamp
            }
            let lastSnapshot = snapshot.children.allObjects.first as! DataSnapshot
            self.startKey = lastSnapshot.key
            completion(newMessages)
        }
    }

    
//    private func fetchMessages(completion: @escaping (_ Message:[Message])->()) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let idsSorted = [uid, user!.uid].sorted()
//        let ref = Database.database().reference().child("Direct/messages/\(idsSorted[0])/\(idsSorted[1])")
//
//        ref.queryOrdered(byChild: "timeStamp").queryLimited(toLast: 16).observeSingleEvent(of: .value) { snapshot in
//            if let dictionaries = snapshot.value as? [String:Any] {
//                dictionaries.forEach { (arg) in
//                    let dictionary = arg.value as! [String:Any]
//                    let message = Message(dictionary: dictionary)
//                    self.messages.append(message)
//                }
//                DispatchQueue.main.async {
//                    self.messages.sort { (m1, m2) -> Bool in
//                        m1.timeStamp > m2.timeStamp
//                    }
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
    
    private func setupNavBarWithUser() {
        let titleView = MessageTableTitleView()
        titleView.usernameLabel.text = user!.username
        titleView.profileImageView.loadImage(urlString: user!.profileImageUrl)
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.red
        navigationItem.titleView = titleView
    }
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let isComing = user?.uid == message.fromId
        if isComing {
            let cell  = tableView.dequeueReusableCell(withIdentifier: cellIdComming, for: indexPath) as! CommingChatMessageCell
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.message = message
            //cell.isComing = user?.uid == message.fromId
            cell.profileImageView.loadImage(urlString: user!.profileImageUrl)
            return cell
        } else {
            let cell  = tableView.dequeueReusableCell(withIdentifier: cellIdGoing, for: indexPath) as! GoingChatMessageCell
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.message = message
            //cell.isComing = user?.uid == message.fromId
            return cell
        }
    }
    
    func didSubmit(for comment: String) {
        
        updateMessagesDataBase(with: comment)
        updateMessagesPreviewDataBase(with: comment)
    }
        
    private func updateMessagesDataBase(with message:String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let idsSorted = [uid, user!.uid].sorted()
        let ref = Database.database().reference().child("Direct/messages/\(idsSorted[0])/\(idsSorted[1])").childByAutoId()
        let values: [String: Any] = ["fromId": uid,
                      "toId": user!.uid,
                      "text": message,
                      "timeStamp": Date().timeIntervalSince1970]
        let message = Message(dictionary: values)
        // update tableView
        messages.insert(message, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        self.tableView.reloadData()
        ref.updateChildValues(values) { (error, ref) in
            if error != nil {
                print("failed to update message")
            }
        }
        self.containerView.clearCommentTextField()
    }
    
    
    private func updateMessagesPreviewDataBase(with message:String) {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = user?.uid else { return }
        let values: [String: Any] = ["fromId": fromId,
                             "toId": toId,
                             "text": message,
                             "timeStamp": Date().timeIntervalSince1970]
        Database.database().reference().child("Direct/messagesPreview/\(fromId)/\(toId)").updateChildValues(values)
        Database.database().reference().child("Direct/messagesPreview/\(toId)/\(fromId)").updateChildValues(values)
    }
    
}

// MARK:- ScrollViewDelegate

extension MessagesTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let verticalIndicator = scrollView.subviews.last as? UIImageView
        verticalIndicator?.backgroundColor = .systemBlue
        let offsetY = scrollView.contentOffset.y + keyboardHeight + containerView.frame.height
        let contentHeight = scrollView.contentSize.height
        print(messages.count)
        
        print("\(offsetY): \(contentHeight)")
        let pos = offsetY > contentHeight - scrollView.frame.size.height
        print("+ve: \(pos)")
        if offsetY > contentHeight - scrollView.frame.size.height {
            if !fetchingMore && !endReached {
                beginBatchFetch()
                print("fetch")
                
            }
        }
    }

    private func beginBatchFetch() {
        fetchingMore = true
        fetchMessages() { newMessages in
            self.messages.append(contentsOf: newMessages)
            self.endReached = newMessages.count == 0
            print(self.messages.count)
            self.fetchingMore = false
            self.tableView.reloadData()
        }
    }
}


extension MessagesTableViewController {
    func startObservingKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    func stopObservingKeyboard() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard presentedViewController?.isBeingDismissed != false else {
            return
        }
        
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame//.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        guard intersection.height != self.keyboardHeight else {
            return
        }

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.keyboardHeight = intersection.height

            // Update contentOffset with new keyboard size
            var contentOffset = self.tableView.contentOffset
            contentOffset.y -= (intersection.height + 200)
            self.tableView.contentOffset = contentOffset

            self.view.layoutIfNeeded()
        }, completion: { _ in
            UIView.performWithoutAnimation {
                self.view.layoutIfNeeded()
            }
        })
    }
    
}


