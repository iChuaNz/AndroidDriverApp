//
//  HomeViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 19/07/24.
//

import UIKit
import MapKit

class HomeViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerSetting: UIView!
    @IBOutlet weak var settingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupSetting(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        containerSetting.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let vc = SettingViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
}
