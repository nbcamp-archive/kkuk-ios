//
//  AddContentViewController.swift
//  Kkuk
//
//  Created by Yujin Kim on 2023-10-16.
//

import SnapKit
import UIKit

class AddContentViewController: BaseUIViewController {
    
    private lazy var induceURLLabel: UILabel = {
        let label = UILabel()
        label.font = .title2
        label.text = "링크 입력 및 붙여넣기"
        label.textColor = .text1
        return label
    }()
    
    private lazy var induceMemoLabel: UILabel = {
        let label = UILabel()
        label.font = .title2
        label.text = "메모하기"
        label.textColor = .text1
        return label
    }()
    
    private lazy var induceCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = .title2
        label.text = "카테고리 고르기"
        return label
    }()
    
    private lazy var URLTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .subgray3
        textField.clearButtonMode = .whileEditing
        textField.font = .body1
        textField.placeholder = "https://www.example.com"
        textField.tintColor = .main
        return textField
    }()
    
    private lazy var memoContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var memoTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .text1
        textView.isScrollEnabled = false
        textView.backgroundColor = .subgray3
        textView.tintColor = .main
        textView.font = .body1
        textView.layer.cornerRadius = CGFloat(5)
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
    
    private lazy var requiredLabel: UILabel = {
        let label = UILabel()
        label.text = "필수"
        label.font = .body3
        label.textColor = .subgray1
        return label
    }()
    
    private lazy var optionalLabel: UILabel = {
        let label = UILabel()
        label.text = "선택"
        return label
    }()
    
    private lazy var closeButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(systemItem: .close)
        barButtonItem.target = self
        return barButtonItem
    }()
    
    private lazy var addContentButton = AddContentButton(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        URLTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setIQKeyboardManagerEnable(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setIQKeyboardManagerEnable(false)
    }
    
    override func setUI() {
        setNavigationBar()
        
        memoContainerView.addSubviews([memoTextView, memoTextCountLabel])
        
        view.addSubviews([induceURLLabel, induceMemoLabel, induceCategoryLabel,
                          URLTextField, memoContainerView, addContentButton])
    }
    
    override func setLayout() {
        induceURLLabel.snp.makeConstraints { constraint in
            constraint.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            constraint.leading.equalTo(20)
        }
        URLTextField.snp.makeConstraints { constraint in
            constraint.top.equalTo(induceURLLabel.snp.bottom).offset(14)
            constraint.leading.equalTo(20)
            constraint.trailing.equalTo(-20)
            constraint.height.equalTo(48)
        }
        induceMemoLabel.snp.makeConstraints { constraint in
            constraint.top.equalTo(URLTextField.snp.bottom).offset(20)
            constraint.leading.equalTo(induceURLLabel)
        }
        memoContainerView.snp.makeConstraints { constraint in
            constraint.top.equalTo(induceMemoLabel.snp.bottom).offset(14)
            constraint.leading.equalTo(induceURLLabel)
            constraint.trailing.equalTo(-20)
            constraint.height.equalTo(142)
        }
        memoTextView.snp.makeConstraints { constraint in
            constraint.edges.equalToSuperview()
        }
        memoTextCountLabel.snp.makeConstraints { constraint in
            constraint.trailing.equalToSuperview().offset(-8)
            constraint.bottom.equalToSuperview().offset(-8)
        }
        induceCategoryLabel.snp.makeConstraints { constraint in
            constraint.top.equalTo(memoTextView.snp.bottom).offset(20)
            constraint.leading.equalTo(induceURLLabel)
        }
        addContentButton.snp.makeConstraints { constraint in
            constraint.bottom.equalToSuperview()
            constraint.leading.trailing.equalToSuperview()
            constraint.height.equalTo(60)
        }
    }
    
    override func setDelegate() {
        URLTextField.delegate = self
        memoTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func addTarget() {}
    
    override func setNavigationBar() {
        title = "추가하기"
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.body1 ]
        appearance.backgroundColor = .white
        appearance.shadowColor = .none
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let closeButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self,
                                              action: #selector(closeButtonItemDidTap))
        navigationItem.rightBarButtonItem = closeButtonItem
    }
    
}

// MARK: - 커스텀 메서드

extension AddContentViewController {
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = view.convert(keyboardFrame, from: nil).size.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.addContentButton.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.addContentButton.transform = .identity
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func closeButtonItemDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITextField 델리게이트

extension AddContentViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        URLTextField.backgroundColor = .background
        URLTextField.layer.borderWidth = CGFloat(2)
        URLTextField.layer.cornerRadius = CGFloat(5)
        URLTextField.layer.borderColor = UIColor.main.cgColor
        URLTextField.layer.masksToBounds = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        URLTextField.backgroundColor = .subgray3
        URLTextField.layer.borderWidth = CGFloat(0)
        URLTextField.layer.borderColor = .none
        addContentButton.updateButtonState(with: URLTextField.text)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updateText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        addContentButton.updateButtonState(with: updateText)
        return true
    }
    
}

// MARK: - UITextView 델리게이트

extension AddContentViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let memoTextViewPlaceholder = "내용"
        if textView.text == memoTextViewPlaceholder {
            textView.text = nil
        }
        
        memoTextView.backgroundColor = .background
        memoTextView.layer.borderColor = UIColor.main.cgColor
        memoTextView.layer.borderWidth = CGFloat(2)
        memoTextView.layer.cornerRadius = CGFloat(5)
        memoTextView.layer.masksToBounds = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let memoTextViewPlaceholder = "내용"
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = memoTextViewPlaceholder
            textView.textColor = .subgray1
        }
        
        memoTextView.backgroundColor = .subgray3
        memoTextView.layer.borderWidth = CGFloat(0)
        memoTextView.layer.borderColor = .none
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        memoTextCountLabel.text = "\(count)/75자"
        if count >= 75 {
            memoTextCountLabel.textColor = .red
        } else {
            memoTextCountLabel.textColor = .subgray1
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentMemoText = memoTextView.text ?? ""
        guard let stringRange = Range(range, in: currentMemoText) else { return false }
        
        let updateMemoText = currentMemoText.replacingCharacters(in: stringRange, with: text)
        return updateMemoText.count <= 75
    }
    
}
