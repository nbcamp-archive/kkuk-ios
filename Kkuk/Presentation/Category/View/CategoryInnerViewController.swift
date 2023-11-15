//
//  CategoryInnerViewController.swift
//  Kkuk
//
//  Created by 장가겸 on 10/24/23.
//

import SnapKit
import UIKit
import RealmSwift

class CategoryInnerViewController: BaseUIViewController {
    private var contentManager = ContentHelper()
    
    private var recentItems: [Content] = [] {
        didSet {
            noContentLabel.isHidden = !recentItems.isEmpty
        }
    }
    
    // "미분류" 카테고리의 ObjectId를 저장할 프로퍼티
    private var uncategorizedCategoryId: ObjectId?
    
    private var category: Category? {
        didSet {
            // "미분류" 카테고리의 ObjectId와 현재 카테고리의 ID를 비교하여 팬모달 버튼을 숨김
            navigationItem.rightBarButtonItem = category?.id == uncategorizedCategoryId ? nil : editButton
        }
    }
    
    private lazy var contentTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .background
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var noContentLabel: UILabel = {
        let label = UILabel()
        label.text = "콘텐츠가 없어요."
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
        let button = UIBarButtonItem(image: UIImage(named: "lucide_circle_ellipsis"), style: .plain, target: self, action: #selector(editButtonDidTapped))
        button.tintColor = .text1
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
    }
    
    func setCategory(category: Category) {
        self.category = category
        // "미분류" 카테고리일 경우 팬모달 버튼을 숨김
        navigationItem.rightBarButtonItem = category.name == "미분류" ? nil: editButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard category != nil else {
            return category = Category()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        let contents = contentManager.readInCategory(at: category?.id ?? Category().id).map { $0 as Content }
        recentItems = contents
        navigationController?.title = category?.name
        contentTableView.reloadData()
    }
    
    private func updatePin(index: Int) {
        contentTableView.reloadRows(at: [.init(row: index, section: 0)], with: .automatic)
    }
    
    override func setUI() {
        view.addSubviews([contentTableView, noContentLabel])
    }
    
    override func setLayout() {
        contentTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
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
        navigationItem.rightBarButtonItem = category?.name == "미분류" ? nil: editButton
    }
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension CategoryInnerViewController {
    
    @objc func editButtonDidTapped() {
        let title = [PanModalOption.Title.modify,
                     PanModalOption.Title.delete,
                     PanModalOption.Title.cancel]
        
        let customVC = PanModalTableViewController(option: PanModalOption(screenType: .category, title: title))
        customVC.delegate = self
        customVC.modalPresentationStyle = .popover
        customVC.selfNavi = navigationController
        customVC.setCategory(category: category!)
        presentPanModal(customVC)
    }
    
}

extension CategoryInnerViewController: PanModalTableViewControllerDelegate {
    func modifyTitle(title: String) {
        navigationItem.title = title
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
        cell.delegate = self
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
        let items = contentManager.read().filter { $0.isPinned }
        if recentItems[index].isPinned == false,
           items.count == 5 {
            let alert = UIAlertController(title: nil, message: "콘텐츠 고정은 5개만 가능해요", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true)
        } else {
            contentManager.update(content: self.recentItems[index]) { [weak self] content in
                content.isPinned.toggle()
                self?.updatePin(index: index)
            }
        }
    }
    
    func presenteMoreMenu(content: Content) {
        let title = [PanModalOption.Title.modify,
                     PanModalOption.Title.delete,
                     PanModalOption.Title.share,
                     PanModalOption.Title.cancel]
        let option = PanModalOption(screenType: .content, title: title)
        let modalVC = PanModalTableViewController(option: PanModalOption(screenType: .content, title: title), content: content)

        modalVC.modalPresentationStyle = .popover
        presentPanModal(modalVC)
    }
}
