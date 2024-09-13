//
//  LoginViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 19/07/24.
//

import UIKit


class LoginViewController: BaseViewController {
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    private let service = NetworkDataFetcher(service: NetworkService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Login"
        self.submitButton.isEnabled = false
        phoneNumberTF.delegate = self
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = UIColor(hex: "FF8B26")
        self.phoneNumberTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        validateTextFieldInput()
    }
    
    func routeToPasscode() {
        let vc = PasscodeViewController()
        vc.phoneNumber = phoneNumberTF.text ?? ""
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
           // Enable or disable button based on whether the text field is empty
           if let text = textField.text, !text.isEmpty {
               submitButton.isEnabled = true
           } else {
               submitButton.isEnabled = false
           }
       }
    
    private func validateTextFieldInput() {
           guard let text = phoneNumberTF.text else {
               return
           }

        if phoneNumberTF.text?.isEmpty == true {
           } else if !isNumericWithoutSpaces(text: text) {
              showBasicModal(title: "Error!", message: "Please enter a valid number")
               return
           } else {
               routeToPasscode()
           }
       }
    
    private func isNumericWithoutSpaces(text: String) -> Bool {
          let regex = "^[0-9]+$"
          let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
          return predicate.evaluate(with: text)
      }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.submitButton.isEnabled = true
//        self.submitButton.tintColor = UIColor(hex: "FF8B26")
    }
}
