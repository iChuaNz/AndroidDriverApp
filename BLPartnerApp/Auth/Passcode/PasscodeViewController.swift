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
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func submitPasscodeTapped(_ sender: Any) {
        let vc = HomeViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    

}
