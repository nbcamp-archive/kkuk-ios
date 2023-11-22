//
//  CategoryCollectionViewCell.swift
//  Kkuk
//
//  Created by 장가겸 on 10/23/23.
//

import RealmSwift
import SnapKit
import UIKit

protocol CategoryTableViewCellDelegate: AnyObject {
    func deleteTableViewCell()
}

class CategoryTableViewCell: BaseUITableViewCell {
    private let categoryHelper = CategoryHelper.shared
    weak var delegate: CategoryTableViewCellDelegate?
    private var category: Category?
    private var id: Int?
    
    private lazy var titleImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "plus")
        imageView.tintColor = .background
        imageView.image = image
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "레이블"
        label.textColor = .text1
        label.numberOfLines = 1
        label.font = .title3
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUI() {
        contentView.addSubviews([titleImage, titleLabel])
        contentView.superview?.backgroundColor = .background
    }
    
    override func setLayout() {
        titleImage.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.height.equalTo(45)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleImage.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
    }
  
    func configure(category: Category) {
        self.category = category
        titleLabel.text = category.name
        titleImage.image = Asset.iconImageList[category.iconId]
    }
}
