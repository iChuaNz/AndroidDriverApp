//
//  PasscodeViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 19/07/24.
//

import UIKit

class PasscodeViewController: UIViewController {
    
    @IBOutlet weak var welcomeTitle: UILabel!
    @IBOutlet weak var passcodeTF: UITextField!
    @IBOutlet weak var submitPasscodeButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var phoneNumber: String = ""
    var userData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Verification Code"
        submitPasscodeButton.isEnabled = false
        
        passcodeTF.delegate = self
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func submitPasscodeTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.postLogin(username: self.phoneNumber, passcode: self.passcodeTF.text ?? "") { result in
                switch result {
                case .success(let responseModel):
                    if responseModel.success, let data = responseModel.data {
                        self.userData = data
                        // Reload the table view or perform any necessary actions with the user data
                        self.routeToHome(userData: data)
                        print("User Data: \(data)")
                    } else {
                        print("Error: \(responseModel.error ?? "Unknown error")")
                    }
                case .failure(let error):
                    print("Failed to fetch data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func routeToHome(userData: UserData) {
        let vc = HomeViewController()
        vc.userData = userData
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
}

extension PasscodeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        submitPasscodeButton.isEnabled = true
    }
}
