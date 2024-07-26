//
//  HomeViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 19/07/24.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces

class HomeViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var containerSetting: UIView!
    @IBOutlet weak var settingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupMaps() {
        let camera = GMSCameraPosition.camera(
            withLatitude:  1.290270, longitude: 103.851959, zoom: 17.0
        )
        self.mapView.camera = camera
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
