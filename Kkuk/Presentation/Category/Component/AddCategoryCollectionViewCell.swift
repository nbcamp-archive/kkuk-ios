//
//  AddCategoryCollectionViewCell.swift
//  Kkuk
//
//  Created by 장가겸 on 10/23/23.
//

import UIKit

class AddCategoryCollectionViewCell: UICollectionViewCell {
    private lazy var titleImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "plus")
        imageView.tintColor = .subgray1
        imageView.image = image
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "추가하기"
        label.textColor = .subgray1
        label.font = .title3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    func setUp() {
        contentView.addSubviews([titleImage, titleLabel])
        contentView.backgroundColor = .systemBackground
        
        titleImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
            make.width.equalTo(contentView.bounds.width / 2)
            make.height.equalTo(contentView.bounds.width / 2)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleImage.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        titleImage.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleImage.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        contentView.layer.cornerRadius = 8.0
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.subgray1.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
