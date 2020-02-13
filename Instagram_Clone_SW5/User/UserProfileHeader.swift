import UIKit

protocol UserProfileHeaderDelegate: AnyObject {
    func didChangeToListView()
    func didChangeToGridView()
    func didTapFollowUnFollowButton()
    func setupHeaderEditFollowButton(for header: UserProfileHeader)
}

class UserProfileHeader: UICollectionViewCell {
    
   
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            userBio.text = user?.bio
            delegate?.setupHeaderEditFollowButton(for: self)
            //setupEditFollowButton()
            setupFollowingAndFollowersButton()
        }
    }
    
    var heightForBio: CGFloat?
    
    weak var delegate: UserProfileHeaderDelegate?
    
    private func setupFollowingAndFollowersButton() {
        guard let user = user else { return }
        
        let followingCount = user.followingCount
        let followersCount = user.followersCount
        let postsCount = user.postsCount
        //
        let followersLabelAttributedString = NSMutableAttributedString(string: "\(followersCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        followersLabelAttributedString.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        self.followersLabel.attributedText = followersLabelAttributedString
        //
        
        let postsLabelAttributedString = NSMutableAttributedString(string: "\(postsCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        postsLabelAttributedString.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        self.postsLabel.attributedText = postsLabelAttributedString
        //
        
        let followingLabelAttributedString = NSMutableAttributedString(string: "\(followingCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        followingLabelAttributedString.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        self.followingLabel.attributedText = followingLabelAttributedString
        
    }
    
    @objc func handleEditProfileOrFollow() {
        delegate?.didTapFollowUnFollowButton()
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            //unfollow
            self.user!.followersCount -= 1
            let attributedText = NSMutableAttributedString(string: "\(self.user!.followersCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            self.followersLabel.attributedText = attributedText
            print("Sucessfully unfollowed user:", self.user!.username)
            self.setupFollowStyle()
        } else if editProfileFollowButton.titleLabel?.text == "Follow" {
            self.user!.followersCount += 1
                     //
            let attributedText = NSMutableAttributedString(string: "\(self.user!.followersCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            self.followersLabel.attributedText = attributedText
            print("Sucessfully followed user: ", self.user?.username ?? "")
            self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
            self.editProfileFollowButton.backgroundColor = .systemBackground
            self.editProfileFollowButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
            self.editProfileFollowButton.layer.borderWidth = 1
            self.editProfileFollowButton.layer.cornerRadius = 3
            self.editProfileFollowButton.setTitleColor(.label, for: .normal)
        }
    }
    
    func setupFollowStyle() {
        editProfileFollowButton.setTitle(("Follow"), for: .normal)
        editProfileFollowButton.backgroundColor = UIColor.systemBlue
        editProfileFollowButton.setTitleColor(.white, for: .normal)
        editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 100 / 2
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var  gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "rectangle.split.3x3")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        //button.setImage(UIImage(systemName: "rectangle.split.3x3")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .selected)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToGridView() {
        gridButton.setImage(UIImage(systemName: "rectangle.split.3x3")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        listButton.setImage(UIImage(systemName: "rectangle.grid.1x2")!.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .normal)
        delegate?.didChangeToGridView()
    }
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "rectangle.grid.1x2")!.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .normal)
        //button.setImage(UIImage(systemName: "rectangle.grid.1x2")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .selected)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToListView() {
        gridButton.setImage(UIImage(systemName: "rectangle.split.3x3")!.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .normal)
        listButton.setImage(UIImage(systemName: "rectangle.grid.1x2")!.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        delegate?.didChangeToListView()
    }
    
    lazy var userBio: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.baselineAdjustment = .none
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
//        let attributedText = NSMutableAttributedString(string: "10\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
//        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
//        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewPost), name: SharePhotoController.updateFeedNotificationName, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewPost), name: SharePhotoController.updateFeedNotificationName, object: nil)
    }
    
    @objc
    func handleNewPost() {
        self.user?.postsCount += 1
        let postsLabelAttributedString = NSMutableAttributedString(string: "\(self.user!.postsCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        postsLabelAttributedString.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        self.postsLabel.attributedText = postsLabelAttributedString
    }
    
    private func sharedInit() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        setupBottomToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 0, paddingRight: 12, width: 0, height: 20)
        
        setupUserStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        //
        addSubview(userBio)
        userBio.anchor(top: usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    }
    
    fileprivate func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .tertiaryLabel
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .tertiaryLabel
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
}
