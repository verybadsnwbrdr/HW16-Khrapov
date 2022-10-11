//
//  ViewController.swift
//  HW16-Khrapov
//
//  Created by Anton on 10.10.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
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
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.placeholder = "Enter password"
        return textField
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.isHidden = true
        return indicator
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray6
        label.text = "Enter password and press Start"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var brutStartStop: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(brutActivate), for: .touchUpInside)
        button.backgroundColor = .systemGray6
        button.setTitle("Start", for: .normal)
        return button
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(onBut), for: .touchUpInside)
        button.setTitle("Change color", for: .normal)
        button.backgroundColor = .systemGray6
        return button
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
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
        stack.addArrangedSubview(button)
        view.addSubview(stack)
        view.addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        textField.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(40)
            make.right.equalTo(view.snp.right).offset(-40)
            make.height.equalTo(50)
        }
        
        button.snp.makeConstraints { make in
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
            make.left.equalTo(textField.snp.left).offset(15)
            make.centerY.equalTo(textField)
        }
    }
    
    // MARK: - Actions
    
    func bruteForce(passwordToUnlock: String) {

        let ALLOWED_CHARACTERS: [String] = String().printable.map { String($0) }
        
        var password: String = ""
        
        while password != passwordToUnlock {
            guard isBrutActive else {
                DispatchQueue.main.async { [self] in
                    guard let password = textField.text else { return }
                    changeLabel(with: "Your password «\(password)» not hacked!")
                    
                    DispatchQueue.main.async { [self] in
                        activityIndicator.isHidden = true
                        activityIndicator.stopAnimating()
                    }
//                    textField.isSecureTextEntry = false
                }
                return
            }
            
            DispatchQueue.main.async { [self] in
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }
            
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            print(password)
            changeLabel(with: password)
        }
        print(password)
        changeLabel(with: "Your password «\(password)»")
        
        DispatchQueue.main.async { [self] in
            isBrutActive.toggle()
            textField.isSecureTextEntry = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }

    }
    
    private func changeLabel(with text: String) {
        DispatchQueue.main.async {
            self.label.text = text
        }
    }
    
    @objc private func onBut() {
        isBlack.toggle()
    }
    
    @objc private func brutActivate() {
        guard let password = textField.text else { return }
        
        guard password != "" else {
            changeLabel(with: "Please, enter password")
            return
        }
        
        isBrutActive.toggle()
        
        let brutQueue = DispatchQueue(label: "brutQueue", qos: .background, attributes: .concurrent)
        brutQueue.async {
            self.bruteForce(passwordToUnlock: password)
        }
    }
}













// MARK: - BruteForce

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index]) : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string

    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }
    
    return str
}



