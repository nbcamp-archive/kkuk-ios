//
//  HomeViewController.swift
//  Kkuk
//
//  Created by Yujin Kim on 2023-10-16.
//

import UIKit

import SnapKit

final class HomeViewController: BaseUIViewController, UIScrollViewDelegate {
    
    private var topFrameView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .main
        
        return view
    }()
    
    private var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이 콘텐츠는 어떠세요?"
        label.font = .subtitle2
        label.textColor = .background
        
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 추천"
        label.font = .title1
        label.textColor = .background
        
        return label
    }()
    
    private var recentLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 보관한 항목"
        label.font = .title3
        label.textColor = .text1
        
        return label
    }()
    
    private var plusButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .main
        button.layer.cornerRadius = 30
        button.setImage(UIImage(named: "Plus"), for: .normal)
        button.tintColor = .background
        
        return button
    }()
    
    private var recommendPagingView = RecommendPagingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        recommendPagingView.setItems(items: ["1111111", "222222222222", "333333333333"])
    }
    
    override func setUI() {
        view.addSubviews([topFrameView, recentLabel, plusButton])
        topFrameView.addSubviews([subTitleLabel, titleLabel, recommendPagingView])
    }
    
    override func setLayout() {
        topFrameView.snp.makeConstraints { constraint in
            constraint.top.equalToSuperview()
            constraint.width.equalTo(view.safeAreaLayoutGuide)
        }
        
        subTitleLabel.snp.makeConstraints { constraint in
            constraint.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            constraint.leading.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { constraint in
            constraint.top.equalTo(subTitleLabel.snp.bottom).offset(8)
            constraint.leading.equalTo(20)
        }
        
        recentLabel.snp.makeConstraints { constraint in
            constraint.top.equalTo(topFrameView.snp.bottom).offset(18)
            constraint.leading.equalTo(20)
        }
        
        recommendPagingView.snp.makeConstraints { constraint in
            constraint.horizontalEdges.equalToSuperview()
            constraint.top.equalTo(titleLabel.snp.bottom).offset(28)
            constraint.bottom.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints { constraint in
            constraint.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            constraint.trailing.equalTo(-20)
            constraint.height.width.equalTo(60)
            
        }
    }
    
    override func setDelegate() {}
    
    override func addTarget() {
        plusButton.addTarget(self, action: #selector(plusButtonDidTap), for: .touchUpInside)
    }
    
}

// MARK: - 커스텀 메서드

extension HomeViewController {
    
    @objc
    private func plusButtonDidTap() {
        let viewController = AddContentViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical
        present(navigationController, animated: true)
    }
    
}
