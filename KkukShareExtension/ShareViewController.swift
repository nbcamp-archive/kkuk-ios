//
//  ShareViewController.swift
//  KkukShareExtension
//
//  Created by Yujin Kim on 2023-11-06.
//

import SnapKit
import Social
import UIKit
import RealmSwift

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1: Set the background and call the function to create the navigation bar
        view.backgroundColor = .systemGray6
        setupNavBar()
        setupViews()
        setLayout()
        
        categories = categoryHelper.read()
    }
    
    // 2: Set the title and the navigation items
    private func setupNavBar() {
        navigationItem.title = "My app"
        
        let closeButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = closeButtonItem

    }
    
//    let service = Category
    
    private var contentHelper = ContentHelper()
    
    private var categoryHelper = CategoryHelper.shared
    
    private var categories = [Category]()
    
    private var selectedCategoryId: ObjectId?
    
    private var sourceURL = ""
    
    private var isAddContent = true
    
    private var modifyContent: Content?

    private lazy var addContentButton = CompleteButton(frame: .zero)
    
    private lazy var induceURLLabel = InduceLabel(text: "링크 입력 및 붙여넣기", font: .title2)
    
    private lazy var induceMemoLabel = InduceLabel(text: "메모하기", font: .title2)
    
    private lazy var induceCategoryLabel = InduceLabel(text: "카테고리 선택하기", font: .title2)
    
    private lazy var optionalLabel = OptionalLabel(frame: .zero)
    
    private lazy var addCategoryButton = RedirectAddCategoryButton(frame: .zero)
    
    private lazy var memoContainerView = UIView()
    
//    private lazy var URLTextField: UITextField = {
//        let textField = UITextField()
//        textField.borderStyle = .roundedRect
//        textField.backgroundColor = .subgray3
//        textField.clearButtonMode = .whileEditing
//        textField.font = .body1
//        textField.placeholder = "https://www.example.com"
//        textField.tintColor = .main
//        textField.layer.cornerRadius = CGFloat(8)
//        textField.clipsToBounds = true
//        return textField
//    }()
    private lazy var URLTextField: UILabel = {
        let label = UILabel()
        label.text = "sdfasdfasdfasdfasfdsadfafsdafsd"
        label.font = .body3
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = false
        return label
    }()
    
    private lazy var URLTextFieldStateLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = .body3
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()
    
    private lazy var memoTextView: UITextView = {
        let textView = UITextView()
        textView.text = "메모할 내용을 입력"
        textView.textColor = .subgray1
        textView.isScrollEnabled = false
        textView.backgroundColor = .subgray3
        textView.tintColor = .main
        textView.font = .body1
        textView.layer.cornerRadius = CGFloat(8)
        textView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 4)
        return textView
    }()
    
    private lazy var memoTextCountLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.text = "0/75자"
        label.textColor = .subgray1
        return label
    }()
    
    private lazy var selectCategoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(SelectCategoryCell.self, forCellWithReuseIdentifier: "SetCategoryCell")
        return view
    }()

    private func setupViews() {
        memoContainerView.addSubviews([memoTextView, memoTextCountLabel])
        
        view.addSubviews([induceURLLabel, induceMemoLabel, induceCategoryLabel, optionalLabel, URLTextField,
                          URLTextFieldStateLabel, memoContainerView, selectCategoryCollectionView, addContentButton, addCategoryButton])
        
        memoTextView.delegate = self
        
        addContentButton.addTarget(self, action: #selector(addContentButtonDidTap), for: .touchUpInside)
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonDidTap), for: .touchUpInside)
        
//        didSelectPost()
    }
    
    private func setLayout() {
        induceURLLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
        }
        URLTextField.snp.makeConstraints {
            $0.top.equalTo(induceURLLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalTo(induceURLLabel)
            $0.height.equalTo(48)
        }
        URLTextFieldStateLabel.snp.makeConstraints {
            $0.top.equalTo(URLTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(induceURLLabel)
        }
        induceMemoLabel.snp.makeConstraints {
            $0.top.equalTo(URLTextFieldStateLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(induceURLLabel)
        }
        optionalLabel.snp.makeConstraints {
            $0.top.trailing.equalTo(induceMemoLabel)
            $0.height.equalTo(induceMemoLabel)
        }
        memoContainerView.snp.makeConstraints {
            $0.top.equalTo(induceMemoLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalTo(induceURLLabel)
            $0.height.equalTo(142)
        }
        memoTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        memoTextCountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalToSuperview().offset(-8)
        }
        induceCategoryLabel.snp.makeConstraints {
            $0.top.equalTo(memoTextView.snp.bottom).offset(28)
            $0.leading.equalTo(induceURLLabel)
        }
        selectCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(induceCategoryLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(induceURLLabel)
            $0.height.equalTo(160)
        }
        addCategoryButton.snp.makeConstraints {
            $0.top.equalTo(induceCategoryLabel)
            $0.trailing.equalTo(induceURLLabel)
            $0.height.equalTo(induceCategoryLabel.snp.height)
        }
        addContentButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8)
            $0.leading.trailing.equalTo(induceURLLabel)
            $0.height.equalTo(60)
        }
    }

    // 3: Define the actions for the navigation items
    @objc private func cancelAction() {
        let error = NSError(domain: "some.bundle.identifier", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error description"])
        extensionContext?.cancelRequest(withError: error)
    }
    
    @objc private func doneAction() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        sourceURL = textField.text ?? ""
        updateAddContentButtonState(with: sourceURL)
    }
    
    @objc
    private func closeButtonItemDidTap() {
        self.dismiss(animated: true, completion: nil)
        self.presentingViewController?.viewDidLoad()
    }
    
    @objc
    private func addContentButtonDidTap() {
        addContentButton.isEnabled = false
        updateActivityIndicatorState(true)
        
        guard let text = URLTextField.text, !text.isEmpty, let URL = URL(string: text) else { return }
        
        let openGraphService = OpenGraphService()
        
        openGraphService.extractOpenGraphData(from: URL) { [weak self] result in
            switch result {
            case .success(let openGraph):
                
                guard let isAddContent = self?.isAddContent else { return }

                if isAddContent {
                    let newContent = Content(sourceURL: text,
                                             title: openGraph.ogTitle ?? "",
                                             imageURL: openGraph.ogImage,
                                             memo: self?.memoTextView.text,
                                             category: (self?.selectedCategoryId)!)
                    self?.contentHelper.create(content: newContent)
                    self?.updateActivityIndicatorState(false)
                    self?.addContentButton.isEnabled = true
                } else {
                    guard let modifyContent = self?.modifyContent else { return }
                    
                    self?.contentHelper.update(content: modifyContent, completion: { content in
                        content.sourceURL = text
                        content.memo = self?.memoTextView.text
                        content.category = (self?.selectedCategoryId)!
                    })
                }

                let title = isAddContent ? "콘텐츠를 추가했어요" : "콘텐츠를 수정했어요"
                
                let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self?.dismiss(animated: true, completion: nil)
                    self?.presentingViewController?.viewDidLoad()
                })
                
                alertController.addAction(okAction)
                self?.present(alertController, animated: true, completion: nil)
                
                print("ogURL: \(openGraph.ogURL ?? "No Data")")
                print("ogTitle: \(openGraph.ogTitle ?? "No Data")")
                print("ogGraph: \(openGraph.ogImage ?? "No Data")")
            case .failure(let error):
                print("Open Graph Data를 추출하는데 문제가 발생했습니다. \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    self?.updateActivityIndicatorState(false)
                    self?.addContentButton.isEnabled = false
                }
            }
        }
    }
    
    @objc
    private func addCategoryButtonDidTap() {
        let viewController = AddCategoryViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    private func updateActivityIndicatorState(_ isEnabled: Bool) {
        addContentButton.configuration?.showsActivityIndicator = isEnabled
    }
    
    private func updateAddContentButtonState(with text: String) {
//        if isValidURL(with: sourceURL), !sourceURL.isEmpty {
//            addContentButton.setUI(to: .enable)
//            URLTextFieldStateLabel.isHidden = false
//            URLTextFieldStateLabel.textColor = .systemBlue
//            URLTextFieldStateLabel.text = "올바른 형식의 링크입니다."
//        }
        
        if sourceURL.isEmpty {
            addContentButton.setUI(to: .disable)
            URLTextFieldStateLabel.isHidden = false
            URLTextFieldStateLabel.textColor = .systemRed
            URLTextFieldStateLabel.text = "링크를 추가해야 합니다."
        }
        
        if sourceURL.range(of: ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*", options: .regularExpression) != nil {
            addContentButton.setUI(to: .disable)
            URLTextFieldStateLabel.isHidden = false
            URLTextFieldStateLabel.textColor = .systemRed
            URLTextFieldStateLabel.text = "지원하지 않는 형식의 링크입니다."
        }
    }
    
//    func didSelectPost() {
//        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
//            let itemProvider = item.attachments?.first as? NSItemProvider,
//            itemProvider.hasItemConformingToTypeIdentifier("public.url") {
//            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { [self] (url, error) in
//                if let shareURL = url as? URL {
//                    do{
//                        try URLTextField.text = String(contentsOf: shareURL)
//                    }
//                    catch{
//                        print("HI")
//                    }
//                }
//            }
//        }
//    }
    
    @available(iOSApplicationExtension, unavailable)
    private func isValidURL(with text: String) -> Bool {
        if let url = NSURL(string: text) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
}

extension ShareViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .background
        textField.layer.borderWidth = CGFloat(2)
        textField.layer.cornerRadius = CGFloat(8)
        textField.layer.borderColor = UIColor.main.cgColor
        textField.layer.masksToBounds = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .subgray3
        textField.layer.borderWidth = CGFloat(0)
        textField.layer.borderColor = .none
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updateText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        updateAddContentButtonState(with: updateText)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ShareViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = .background
        textView.layer.borderColor = UIColor.main.cgColor
        textView.layer.borderWidth = CGFloat(2)
        textView.layer.cornerRadius = CGFloat(8)
        textView.layer.masksToBounds = true
        
        if textView.textColor == .subgray1 {
            textView.text = nil
            textView.textColor = .text1
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.textColor = .text1
        textView.backgroundColor = .subgray3
        textView.layer.borderWidth = CGFloat(0)
        textView.layer.borderColor = .none
        
        if textView.textColor == .subgray1 {
            textView.text = "메모할 내용을 입력"
            textView.textColor = .subgray1
        }
        
        if textView.text == "메모할 내용을 입력" {
            textView.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        memoTextCountLabel.text = "\(count)/75자"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentMemoText = memoTextView.text ?? ""
        guard let stringRange = Range(range, in: currentMemoText) else { return false }
        
        let updateMemoText = currentMemoText.replacingCharacters(in: stringRange, with: text)
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return updateMemoText.count <= 75
    }
}

extension ShareViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        selectedCategoryId = category.id
        
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectCategoryCell {
            cell.isSelected = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectCategoryCell {
            cell.isSelected = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetCategoryCell", for: indexPath) as? SelectCategoryCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.item]
        cell.configure(with: category)
        
        return cell
    }
}

extension ShareViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 4) - 4
        return CGSize(width: width, height: 48)
    }
}
