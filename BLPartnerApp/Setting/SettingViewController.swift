//
//  SettingViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 23/07/24.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var containerScrollView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var horizontalStackView: UIStackView!
    @IBOutlet weak var userIdTitle: UILabel!
    @IBOutlet weak var userIdValue: UILabel!
    @IBOutlet weak var versionTitle: UILabel!
    @IBOutlet weak var versionValue: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
    }
    
    func setupUI () {
        versionValue.text = Bundle.main.releaseVersionNumber
    }
}
