//
//  CategoryInnerViewController.swift
//  Kkuk
//
//  Created by 장가겸 on 10/24/23.
//

import SnapKit
import UIKit

class CategoryInnerViewController: BaseUIViewController {
    let contentList: [String] = ["ddddd"]
    
    private lazy var contentTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        let leftBarButton = UIBarButtonItem(title: "카테고리", style: .plain, target: self, action: #selector(categoryButtonTapped))
        let navLabel = UINavigationItem(title: "카테고리 이름")
        navLabel.leftBarButtonItem = leftBarButton
        leftBarButton.tintColor = .main
        navigationBar.setItems([navLabel], animated: true)
        return navigationBar
    }()
    
    private lazy var noContentLabel: UILabel = {
        let label = UILabel()
        label.text = "아카이브가 없습니다"
        label.font = .subtitle2
        label.textColor = .text1
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isHidden = !contentList.isEmpty
        return label
    }()

    override func setUI() {
        view.addSubviews([navigationBar, contentTableView, noContentLabel])
    }
    
    override func setLayout() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        contentTableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
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
    
    @objc func categoryButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension CategoryInnerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contentTableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath)
        return cell
    }
}
