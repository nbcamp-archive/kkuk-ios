//
//  CategoryInnerViewController.swift
//  Kkuk
//
//  Created by 장가겸 on 10/24/23.
//

import SnapKit
import UIKit

class CategoryInnerViewController: BaseUIViewController {
    
    private var contentManager = ContentHelper()
    
    private var recentItems: [Content] = [] {
        didSet {
            noContentLabel.isHidden = !recentItems.isEmpty
        }
    }
    
    private var category: Category?
    
    private lazy var contentTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var noContentLabel: UILabel = {
        let label = UILabel()
        label.text = "아카이브가 없습니다"
        label.font = .subtitle2
        label.textColor = .text1
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isHidden = !recentItems.isEmpty
        return label
    }()
    
    private lazy var backButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(image: Asset.back.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backButtonDidTap))
        buttonItem.tintColor = .selected
        return buttonItem
    }()
    
    private lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "editCategory"), style: .plain, target: self, action: #selector(editButtonDidTapped))
        button.tintColor = .text1
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard category != nil else {
            return self.category = Category()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let contents = contentManager.readInCategory(at: category?.id ?? Category().id).map { $0 as Content }
        recentItems = contents
        navigationController?.title = category?.name
        contentTableView.reloadData()
    }

    override func setUI() {
        view.addSubviews([contentTableView, noContentLabel])
    }
    
    override func setLayout() {
        contentTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        noContentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    override func setDelegate() {
        contentTableView.delegate = self
        contentTableView.dataSource = self
    }
    
    override func setNavigationBar() {
        title = category?.name
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.rightBarButtonItem = editButton
    }
}

extension CategoryInnerViewController {
    @objc func backButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc func editButtonDidTapped() {
        let title = [PanModalOption.Title.modify,
                     PanModalOption.Title.delete,
                     PanModalOption.Title.cancel]
        
        let customVC = PanModalTableViewController(option: PanModalOption(screenType: .category, title: title))
        customVC.delegate = self
        customVC.modalPresentationStyle = .popover
        customVC.setCategory(category: self.category!)
        self.presentPanModal(customVC)
    }
    
    func setCategory(category: Category) {
        self.category = category
    }
}

extension CategoryInnerViewController: PanModalTableViewControllerDelegate {
    func modifyTitle(title: String) {
        self.navigationItem.title = title
    }
}

extension CategoryInnerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell",
                                                       for: indexPath) as? ContentTableViewCell
        else { return UITableViewCell() }
        let item = recentItems[indexPath.row]
        cell.configureCell(content: item, index: indexPath.row)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = recentItems[indexPath.row]
        
        let url = item.sourceURL
        let title = item.title
        
        let viewController = WebViewController(sourceURL: url, sourceTitle: title)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }    
}

extension CategoryInnerViewController: ContentTableViewCellDelegate {
    func togglePin(index: Int) {
    }
    
    func presenteMoreMenu(content: Content) {
        let title = [PanModalOption.Title.modify,
                     PanModalOption.Title.delete,
                     PanModalOption.Title.share,
                     PanModalOption.Title.cancel]
        let option = PanModalOption(screenType: .content, title: title)
        let modalVC = PanModalTableViewController(option: option, content: content)
        modalVC.modalPresentationStyle = .popover
        presentPanModal(modalVC)
    }
}
