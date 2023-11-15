//
//  SearchContentViewController.swift
//  Kkuk
//
//  Created by Yujin Kim on 2023-10-16.
//

import UIKit

class SearchContentViewController: BaseUIViewController {
    
    var contentList: [Content] = []
    
    let recentSearchContentViewController = RecentSearchContentViewController()
    let contentManager = ContentHelper()
    let recenteSearchManager = RecentSearchHelper()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색어를 입력하세요"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.configureCommonStyle()
        searchBar.searchTextField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        return searchBar
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let items = [SegmentMenu.title.name, SegmentMenu.memo.name]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = items.startIndex
        segment.addTarget(self, action: #selector(didChangeSegmentIndex(_:)), for: .valueChanged)
        return segment
    }()
    
    private lazy var contentTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .background
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var noContentLabel: UILabel = {
        let label = UILabel()
        label.text = "콘텐츠가 없습니다"
        label.font = .subtitle2
        label.textColor = .text1
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isHidden = !contentList.isEmpty
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubview(recentSearchContentViewController.view)
        return view
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let presentedViewController = self.presentedViewController as? PanModalTableViewController else {
            searchBar.text = ""
            toggleContainerViewVisibility(isShow: true)
            return }
    }
    
    override func setTopView() {
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.2)
        }
        
        topTitle.text = "검색"
        topView.addSubviews([topTitle])
        topTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(28)
            make.leading.equalTo(20)
        }
    }

    private func updatePin(index: Int) {
        contentTableView.reloadRows(at: [.init(row: index, section: 0)], with: .automatic)
    }

    override func setUI() {
        addChild(recentSearchContentViewController)
        recentSearchContentViewController.didMove(toParent: self)
        
        view.addSubviews([searchBar,
                          segmentedControl,
                          contentTableView,
                          noContentLabel,
                          containerView])
    }
    
    override func setLayout() {
        setSearchBarLayout()
        setSegmentedControl()
        setContentTableViewLayout()
        setNoContentLabelLayout()
        setContainerViewLayout()
    }
    
    override func setDelegate() {}
    
    override func addTarget() {}
    
    func reloadData() {
        guard let searchText = searchBar.text else { return }
        guard let column = SegmentMenu(rawValue: segmentedControl.selectedSegmentIndex) else { return }

        let realm = ContentHelper()
        
        contentList = realm.read(at: column, with: searchText)
        
        contentTableView.reloadData()
        noContentLabel.isHidden = !contentList.isEmpty
    }
    
    func setSearchBarLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setSegmentedControl() {
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setContentTableViewLayout() {
        contentTableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setNoContentLabelLayout() {
        noContentLabel.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
        }
    }
    
    func setContainerViewLayout() {
        containerView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        recentSearchContentViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(containerView.snp.edges)
        }
    }
    
    @objc func didChangeSegmentIndex(_ sender: UISegmentedControl) {
        reloadData()
    }
}

extension SearchContentViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            toggleContainerViewVisibility(isShow: true)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        toggleTextFieldStyle(isTapped: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        toggleTextFieldStyle(isTapped: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        reloadData()
        toggleContainerViewVisibility(isShow: false)
        recenteSearchManager.add(to: searchText)
    }
    
    func toggleContainerViewVisibility(isShow: Bool) {
        containerView.isHidden = !isShow
        recentSearchContentViewController.reloadData()
    }
    
    func toggleTextFieldStyle(isTapped: Bool) {

        if isTapped {
            searchBar.searchTextField.configureForEditing()
            searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)

        } else {
            searchBar.searchTextField.configureCommonStyle()
        }
        
        setIQKeyboardManagerEnable(isTapped)
    }
}

extension SearchContentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = contentTableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        
        let content = contentList[indexPath.row]
        cell.configureCell(content: content, index: indexPath.row)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = contentList[indexPath.row]
        
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

extension SearchContentViewController: ContentTableViewCellDelegate {
    func togglePin(index: Int) {
        let items = contentManager.read().filter { $0.isPinned }
        if contentList[index].isPinned == false,
           items.count == 5 {
            let alert = UIAlertController(title: nil, message: "콘텐츠 고정은 5개만 가능해요", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true)
        } else {
            contentManager.update(content: self.contentList[index]) { [weak self] content in
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
