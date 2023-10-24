//
//  CategoryViewController.swift
//  Kkuk
//
//  Created by Yujin Kim on 2023-10-16.
//

import SnapKit
import UIKit

class CategoryViewController: BaseUIViewController {
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: UIScreen.main.bounds.height / 4)
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.register(AddCategoryCollectionViewCell.self, forCellWithReuseIdentifier: "AddCategoryCollectionViewCell")
        collectionView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var color: [UIColor] = [.systemGray, .systemOrange, .systemYellow, .systemGreen]
    
    override func setUI() {
        view.addSubview(categoryCollectionView)
    }
    
    override func setLayout() {
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setDelegate() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
    }
    
    override func addTarget() {}
}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return color.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath[1]
        if index == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCategoryCollectionViewCell",
                                                                for: indexPath) as? AddCategoryCollectionViewCell else { return UICollectionViewCell() }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell",
                                                                for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
            let color = color[indexPath.item - 1]
            cell.contentView.backgroundColor = color
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath[1]
        if index == 0 {
            let customVC = AddCategoryViewController()
            let navController = UINavigationController(rootViewController: customVC)
            present(navController, animated: true, completion: nil)
        } else {
            let customVC = CategoryInnerViewController()
            customVC.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(customVC, animated: true)
        }
    }
}
