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
    @IBOutlet weak var containerEndtTripView: UIView!
    @IBOutlet weak var routeCodeLabel: UILabel!
    @IBOutlet weak var containerRouteCode: UIView!
    @IBOutlet weak var endTripLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        mapView.delegate = self
        setupMaps()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupMaps() {
        DispatchQueue.main.async {
            let camera = GMSCameraPosition.camera(
                withLatitude:  1.287953, longitude: 103.851784, zoom: 17.0
            )
            self.mapView.camera = camera
        }
        self.mapView.bringSubviewToFront(containerEndtTripView)
        setupSetting()
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

extension HomeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let camera = GMSCameraPosition.camera(withLatitude: 1.287953, longitude: 103.851784, zoom: 17.0)
        mapView.camera = camera
    }
}
