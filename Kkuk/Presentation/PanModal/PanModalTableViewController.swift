//
//  PanModalTableViewController.swift
//  Kkuk
//
//  Created by 장가겸 on 10/25/23.
//

import PanModal
import SnapKit
import UIKit
import RealmSwift

protocol PanModalTableViewControllerDelegate: AnyObject {
    func modifyTitle(title: String)
}

class PanModalTableViewController: BaseUIViewController {
    private var category: Category?

    private var modifyTitle: String?

    weak var delegate: PanModalTableViewControllerDelegate?
    
    private var panModalOption: PanModalOption?
    
    private var content: Content?
    
    private var helper = ContentHelper()
    
    weak var selfNavi: UINavigationController?

    private lazy var deleteModifyTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PanModalTableViewCell.self, forCellReuseIdentifier: "PanModalTableViewCell")
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.estimatedRowHeight = 34
        return tableView
    }()
    
    init(option: PanModalOption, content: Content? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.panModalOption = option
        self.content = content
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setUI() {
        view.addSubview(deleteModifyTableView)
    }

    /// 화면 레이아웃을 설정하기 위한 사용자 정의 함수입니다.
    override func setLayout() {
        deleteModifyTableView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 델리게이트 설정을 위한 사용자 정의 함수입니다.
    override func setDelegate() {
        deleteModifyTableView.delegate = self
        deleteModifyTableView.dataSource = self
        deleteModifyTableView.allowsSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        delegate?.modifyTitle(title: modifyTitle ?? category!.name)
    }

    private func presentDeleteAlert() {
        
        let title = panModalOption?.screenType == .category ? "카테고리" : "콘텐츠"
        
        showAlertTwoButton(title: "\(title)를 삭제하시겠습니까?", message: nil, actionCompletion: {
            
            switch self.panModalOption?.screenType {
            case .category:
                guard let category = self.category else { return }
                
                // ContentHelper 인스턴스를 생성
                let contentHelper = ContentHelper()
                
                // 카테고리에 속한 콘텐츠를 찾아서 삭제
                let contentsToDelete = contentHelper.readInCategory(at: category.id)
                for content in contentsToDelete {
                    contentHelper.delete(content)
                }

                // CategoryHelper를 사용하여 카테고리 삭제
                CategoryHelper.shared.delete(category)
                
                // 뷰 컨트롤러 닫기
            case .content:
                guard let content = self.content else { return }
                self.helper.delete(content)
            default: return
            }

            self.selfNavi?.popToRootViewController(animated: true)
            self.dismiss(animated: true)
        })
    }

}

extension PanModalTableViewController {
    func setCategory(category: Category) {
        self.category = category
    }
}

extension PanModalTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = panModalOption?.title.count else { return 0 }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let title = panModalOption?.title[indexPath.row] else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PanModalTableViewCell",
                                                       for: indexPath) as? PanModalTableViewCell else { return UITableViewCell() }
        cell.configure(name: title.rawValue)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let count = panModalOption?.title.count else { return 0 }
        return (UIScreen.main.bounds.height * 0.25 ) / CGFloat(count)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menu = panModalOption?.title[indexPath.row] else { return }
        switch panModalOption?.screenType {
        case .category: didSelectedCategoryScreen(menu)
        case .content: didSelectedContentScreen(menu)
        default: return
        }
    }
    
    func didSelectedCategoryScreen(_ menu: PanModalOption.Title) {
        switch menu {
        case .modify:
            let viewController = AddCategoryViewController(isAddCategory: false, modifyCategory: category) { [weak self] in
                self?.completion?(())
            }
            viewController.delegate = self
            presentFromPanModal(to: viewController)
        case .delete:
            self.presentDeleteAlert()
        case .cancel:
            dismiss(animated: true)
        default:
            return
        }
    }
    
    func didSelectedContentScreen(_ menu: PanModalOption.Title) {
        guard let content = content else { return }
        
        switch menu {
        case .modify:
            let viewController = AddContentViewController(isAddContent: false, modifyContent: content) { [weak self] in
                self?.completion?(())
            }
            viewController.delegate = self
            presentFromPanModal(to: viewController)
        case .delete:
            presentDeleteAlert()
        case .share:
            guard let url = URL(string: content.sourceURL) else { return }
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityViewController, animated: true)
        case .cancel: dismiss(animated: true)
        }
    }
    
    func presentFromPanModal(to viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical
        present(navigationController, animated: true)
    }
}

extension PanModalTableViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        deleteModifyTableView
    }

    var shortFormHeight: PanModalHeight {
        .contentHeight(UIScreen.main.bounds.height * 0.25)
    }

    var longFormHeight: PanModalHeight {
        .contentHeight(UIScreen.main.bounds.height * 0.25)
    }

    var allowsTapToDismiss: Bool {
        true
    }

    var dragIndicatorBackgroundColor: UIColor {
        .clear
    }
}

extension PanModalTableViewController: AddCategoryViewControllerDelegate, AddContetnViewControllerDelegate {
    func dismissModal() {
        completion?(())
        dismiss(animated: false)
    }

    func reloadTableView() {}
}
