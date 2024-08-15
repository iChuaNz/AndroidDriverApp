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

class HomeViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var containerEndtTripView: UIView!
    @IBOutlet weak var routeCodeLabel: UILabel!
    @IBOutlet weak var containerRouteCode: UIView!
    @IBOutlet weak var endTripLabel: UILabel!
    @IBOutlet weak var markerImageView: UIImageView!
    var userData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postAll() { result in
            switch result {
            case .success(let responseModel):
                if responseModel.success, let data = responseModel.data {
                    print("success post all job")
                } else {
                    print("success post all job")
                }
            case .failure(let error):
                print("success post all job")
            }
        }
        setupMaps()
        setupScheduledView()
    }
    
    func setupScheduledView() {
        let scheduledVC = ScheduledViewController()
        scheduledVC.modalPresentationStyle = .formSheet
        scheduledVC.transitioningDelegate = self
        present(scheduledVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        let customBackButton = UIBarButtonItem(
            title: "Profile",
            style: .plain,
            target: self,
            action: #selector(handleTap))
        self.navigationItem.leftBarButtonItem = customBackButton
        self.navigationItem.title = "Tracker"
    }
    
    func setupMaps() {
        DispatchQueue.main.async {
            let camera = GMSCameraPosition.camera(
                withLatitude:  1.287953, longitude: 103.851784, zoom: 17.0
            )
            self.mapView.camera = camera
        }
        
        self.mapView.bringSubviewToFront(containerEndtTripView)
        self.mapView.bringSubviewToFront(markerImageView)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let vc = SettingViewController()
        vc.userData = userData
        navigationController?.pushViewController(vc, animated: false)
    }
    func postAll(completion: @escaping (Result<ResponseJobs, Error>) -> Void) {
        guard let url = URL(string: "https://bustrackerstaging.azurewebsites.net/api/2/Jobs") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(userData?.token ?? "", forHTTPHeaderField: "token")
//        [request setValue:token forHTTPHeaderField:@"token"];
        
        
//        let parameters: [String: Any] = [
//            "token": userData?.token ?? "",
//        ]
        
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // Create a URLSession
        let session = URLSession.shared
        BasicAlert.shared.showLoading(self.view)
        // Create the data task
        let task = session.dataTask(with: request) { data, response, error in
            // Handle the response
            if let error = error {
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    self.showAlert(title: "Invalid", message: "Authentication Invalid")
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let responseError = NSError(domain: "InvalidResponse", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    self.showAlert(title: "Invalid", message: "Authentication Invalid")
                    completion(.failure(responseError))
                }
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let responseModel = try decoder.decode(ResponseJobs.self, from: data)
                    DispatchQueue.main.async {
                        BasicAlert.shared.dismiss()
                        completion(.success(responseModel))
                    }
                } catch {
                    DispatchQueue.main.async {
                        BasicAlert.shared.dismiss()
                        self.showAlert(title: "Invalid", message: "Authentication Invalid")
                        completion(.failure(error))
                    }
                }
            } else {
                let parseError = NSError(domain: "DataParseError", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    self.showAlert(title: "Invalid", message: "Authentication Invalid")
                    completion(.failure(parseError))
                }
            }
        }
        task.resume()
    }
}

extension HomeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let camera = GMSCameraPosition.camera(withLatitude: 1.287953, longitude: 103.851784, zoom: 17.0)
        mapView.camera = camera
    }
}
