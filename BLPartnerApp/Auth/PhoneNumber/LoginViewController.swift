//
//  LoginViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 19/07/24.
//

import UIKit


class LoginViewController: UIViewController {
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    private let service = NetworkDataFetcher(service: NetworkService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        postLogin(with: phoneNumberTF.text ?? "", phoneNumber: phoneNumberTF.text ?? "")
        print("==== \(UserDefaults.standard.string(forKey: "DeviceToken"))")
    }
    
    func routeToHome() {
        let vc = PasscodeViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func postLogin(with passcode: String, phoneNumber: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.service.postLogin(endpoint: .getLogin(passcode, phoneNumber)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let articles):
                    routeToHome()
                case .failure(let error):
                    routeToHome()
                }
            }
        }
    }
}
