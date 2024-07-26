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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func submitPasscodeTapped(_ sender: Any) {
        DispatchQueue.main.async { 
            self.postLogin(username: self.phoneNumber, passcode: self.passcodeTF.text ?? "") { result in
                switch result {
                    case .success(let responseString):
                        self.routeToHome()
                        print("=== Response data: \(responseString)")
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
            }
        }
    }
    
    func routeToHome() {
        let vc = HomeViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }

}
