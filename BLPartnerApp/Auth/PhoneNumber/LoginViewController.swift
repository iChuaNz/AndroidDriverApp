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
        routeToPasscode()
    }
    
    func routeToPasscode() {
        let vc = PasscodeViewController()
        vc.phoneNumber = phoneNumberTF.text ?? ""
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
}
