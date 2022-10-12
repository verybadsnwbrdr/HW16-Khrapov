//
//  ViewController.swift
//  HW16-Khrapov
//
//  Created by Anton on 10.10.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - Stored Properties
    
    private var isBlack: Bool = false {
        didSet {
            self.view.backgroundColor = isBlack ? .white : .black
        }
    }
    
    private var isBrutActive: Bool = false {
        didSet {
            let buttonLabel = isBrutActive ? "Stop" : "Start"
            brutStartStop.setTitle(buttonLabel, for: .normal)
        }
    }
    
    // MARK: - Elements
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray2
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.placeholder = "Enter password"
        textField.layer.cornerRadius = 15
        return textField
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.isHidden = true
        return indicator
    }()
    
    private lazy var secureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.addTarget(self, action: #selector(toggleSecureButtonAndTextField), for: .touchUpInside)
        button.tintColor = .label
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 15
        return button
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray2
        label.text = "Enter password and press Start"
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var brutStartStop: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(brutActivate), for: .touchUpInside)
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = 15
        button.setTitle("Start", for: .normal)
        button.tintColor = .label
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return button
    }()
    
    private lazy var changeBackColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(changeBackColor), for: .touchUpInside)
        button.setTitle("Change color", for: .normal)
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = 15
        button.tintColor = .label
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return button
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
    }
    
    // MARK: - Setup
    
    private func setupHierarchy() {
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(brutStartStop)
        stack.addArrangedSubview(changeBackColorButton)
        view.addSubview(stack)
        view.addSubview(activityIndicator)
        view.addSubview(secureButton)
    }
    
    private func setupLayout() {
        textField.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(40)
            make.right.equalTo(view.snp.right).offset(-40)
            make.height.equalTo(50)
        }
        
        changeBackColorButton.snp.makeConstraints { make in
            make.left.right.height.equalTo(textField)
        }
        
        brutStartStop.snp.makeConstraints { make in
            make.left.right.height.equalTo(textField)
        }
        
        label.snp.makeConstraints { make in
            make.left.right.height.equalTo(textField)
        }
        
        stack.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.right.equalTo(textField.snp.right).offset(-20)
            make.centerY.equalTo(textField)
        }
        
        secureButton.snp.makeConstraints { make in
            make.left.equalTo(textField.snp.left).offset(20)
            make.centerY.equalTo(textField)
            make.width.equalTo(25)
            make.height.equalTo(20)
        }
    }
    
    // MARK: - Actions
    
    private func toggleSecureButtonImage() {
        if secureButton.currentImage == UIImage(systemName: "eye.slash") {
            secureButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            secureButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    private func brutStopAndChangeLabel(with text: String) {
        label.text = text
        isBrutActive.toggle()
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Buttons Actions
    
    @objc private func changeBackColor() {
        isBlack.toggle()
    }
    
    @objc private func brutActivate() {
        guard let password = textField.text, password != "" else { return label.text = "Please, enter password" }
        isBrutActive.toggle()
        
        let brutQueue = DispatchQueue(label: "brutQueue", qos: .background, attributes: .concurrent)
        brutQueue.async { [self] in
            bruteForce(passwordToUnlock: password)
        }
    }
    
    @objc private func toggleSecureButtonAndTextField() {
        toggleSecureButtonImage()
        textField.isSecureTextEntry.toggle()
    }
}

// MARK: - BruteForce Extension

extension ViewController {
    private func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS: [String] = String().printable.map { String($0) }
        var password: String = ""
        
        while password != passwordToUnlock {
            if !isBrutActive {
                DispatchQueue.main.async { [self] in
                    brutStopAndChangeLabel(with: "Your password «\(passwordToUnlock)» not hacked!")
                }
                return
            }
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            DispatchQueue.main.async { [self] in
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                label.text = password
            }
        }
        
        DispatchQueue.main.async { [self] in
            brutStopAndChangeLabel(with: "Your password «\(password)»")
            if textField.isSecureTextEntry {
                toggleSecureButtonAndTextField()
            }
        }
    }
    
    private func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }
    
    private func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index]) : Character("")
    }
    
    private func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string
        
        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        } else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }
        return str
    }
}




