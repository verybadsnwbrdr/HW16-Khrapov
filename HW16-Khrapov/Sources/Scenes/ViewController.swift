//
//  ViewController.swift
//  HW16-Khrapov
//
//  Created by Anton on 10.10.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var isBlack: Bool = false {
        didSet {
            self.view.backgroundColor = isBlack ? .white : .black
        }
    }
    
    // MARK: - Elements

    private lazy var textField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var anotherButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(onBut), for: .touchUpInside)
        button.setTitle("Button", for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.bruteForce(passwordToUnlock: "1!gr")
        setupHierarchy()
        setupLayout()
    }
    
    // MARK: - Setup
    
    private func setupHierarchy() {
        view.addSubview(button)
    }
    
    private func setupLayout() {
        button.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    // MARK: - Actions
    
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS: [String] = String().printable.map { String($0) }

        var password: String = ""

        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock { // Increase MAXIMUM_PASSWORD_SIZE value for more
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            // Your stuff here
            print(password)
            // Your stuff here
        }
        print(password)
    }
    
    @objc private func onBut() {
        isBlack.toggle()
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



