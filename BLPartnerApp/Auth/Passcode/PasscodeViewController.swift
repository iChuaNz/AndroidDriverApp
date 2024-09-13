//
//  PasscodeViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 19/07/24.
//

import UIKit

class PasscodeViewController: BaseViewController {
    
    @IBOutlet weak var welcomeTitle: UILabel!
    @IBOutlet weak var passcodeTF: UITextField!
    @IBOutlet weak var submitPasscodeButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var phoneNumber: String = ""
    var userData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Verification Code"
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        submitPasscodeButton.isEnabled = false
        self.passcodeTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passcodeTF.delegate = self
    }
    
    @IBAction func submitPasscodeTapped(_ sender: Any) {
        guard let text = passcodeTF.text else {
            return
        }
        if text.count != 6 {
            showBasicModal(title: "Error!", message: "Invalid 6 digit code entered")
            return
        }
        DispatchQueue.main.async {
            self.postLogin(username: self.phoneNumber, passcode: self.passcodeTF.text ?? "") { [weak self] result in
                switch result {
                case .success(let responseModel):
                    if responseModel.success, let data = responseModel.data {
                        self?.userData = data
                        // Reload the table view or perform any necessary actions with the user data
                        self?.routeToHome(userData: data)
                        UserDefaults.standard.set(data.token, forKey: "token")
                        print("User Data: \(data)")
                    } else {
                        self?.showBasicModal(title: "Error!", message: "Failed fetch data")
                    }
                case .failure(let error):
                    self?.showBasicModal(title: "Error!", message: "Something wrong \(error.localizedDescription)")
                }
            }
        }
    }
    
    func routeToHome(userData: UserData) {
        let vc = HomeViewController()
        vc.userData = userData
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
           // Enable or disable button based on whether the text field is empty
           if let text = textField.text, !text.isEmpty {
               submitPasscodeButton.isEnabled = true
           } else {
               submitPasscodeButton.isEnabled = false
           }
       }
}

extension PasscodeViewController: UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        submitPasscodeButton.isEnabled = true
//    }
}
