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
import CoreLocation

class HomeViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var markerImageView: UIImageView!
    @IBOutlet weak var containerScheduledView: UIView!
    @IBOutlet weak var destinationTitleTripLabel: UILabel!
    @IBOutlet weak var goTime: UILabel!
    @IBOutlet weak var startPoinnt: UILabel!
    @IBOutlet weak var endPoint: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var vehicleNumber: UILabel!
    var userData: UserData?
    var tripsData: TripsData?
    let locationManager = CLLocationManager()
    var timer: Timer?
    var currentLocation: CLLocation?
    @IBOutlet weak var calendarImage: UIImageView!
    var isLocationRetrieved = false
    
    let pathData: [[String: Double]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //        let pulseView = PulsingView()
        //        pulseView.translatesAutoresizingMaskIntoConstraints = false
        //        pulseView.center = CGPoint(x: markerImageView.bounds.midX, y: markerImageView.bounds.midY + -30)
        //        self.mapView.addSubview(pulseView)
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        // Request permission
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        self.postAll() { result in
            switch result {
            case .success(let responseModel):
                if responseModel.success == false {
                    self.showBasicModal(title: "Info", message: "This job is already expired")
                }
                if responseModel.success, let data = responseModel.data {
                    self.tripsData = data
                    let startpoint = data.points?.first?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
                    let endpoint = data.points?.last?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
                    
                    self.startPoinnt.text = startpoint?.capitalized
                    self.endPoint.text = endpoint?.capitalized
                    self.goTime.text = (data.points?.first?.time ?? "") + " to " + (data.points?.last?.time ?? "")
                    self.setupUI()
                } else {
                    print("All trips data is empty.")
                }
            case .failure(let error):
                print("failed post all job")
            }
        }
        startTimer()
        routeToScheduled()
        containerScheduledView.layer.cornerRadius = 16
        containerScheduledView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top left and top right corners only
        containerScheduledView.clipsToBounds = true
    }
    
    func setupUI() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        calendarImage.isUserInteractionEnabled = true
        calendarImage.addGestureRecognizer(tapGestureRecognizer)
        let tapToMaps = UITapGestureRecognizer(target: self, action: #selector(routeToGmaps))
        notificationIcon.isUserInteractionEnabled = true
        notificationIcon.addGestureRecognizer(tapToMaps)
        
        self.vehicleNumber.text = "Vehicle No: " + (tripsData?.vehicleNo ?? "-")
        if tripsData?.codeName?.lowercased() == "adhoc" {
            if tripsData?.adhoc?.serviceType?.lowercased() == "disposal" {
                if let codeName = tripsData?.codeName,
                   let adhoc = tripsData?.adhoc {
                    let duration = adhoc.duration ?? ""
                    let serviceType = adhoc.serviceType ?? ""
                    self.destinationTitleTripLabel.text = (tripsData?.codeName ?? "") + " (\(duration)h \(serviceType))"
                } else {
                    self.destinationTitleTripLabel.text = (tripsData?.codeName ?? "") + " (\(tripsData?.adhoc?.serviceType ?? ""))"
                }
            } else {
                if self.tripsData?.adhoc?.serviceType?.isEmpty == true {
                    self.destinationTitleTripLabel.text = (tripsData?.codeName ?? "")
                } else {
                    self.destinationTitleTripLabel.text = (tripsData?.codeName ?? "") + " (\(tripsData?.adhoc?.serviceType ?? ""))"
                }
            }
            self.finishButton.isHidden = false
        } else {
            if self.tripsData?.adhoc?.serviceType?.isEmpty == true {
                self.destinationTitleTripLabel.text = (tripsData?.codeName ?? "")
            } else {
                self.destinationTitleTripLabel.text = (tripsData?.codeName ?? "") + " (\(tripsData?.adhoc?.serviceType ?? "-"))"
            }
        }
    }
    
    @objc func routeToGmaps(){
        if let url = generateGoogleMapsURL(from: tripsData?.points ?? [Point]()) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func generateGoogleMapsURL(from points: [Point]) -> URL? {
        // Find the destination point
        guard let destination = points.first(where: { $0.type == 1 }) else {
            showAlert(title: "Missing Point", message: "Destination point is missing")
            return nil
        }
        
        // Extract waypoints (intermediate points)
        let waypoints = points
            .filter { $0.type != 1 }  // Exclude the destination point
            .map { "\($0.latitude),\($0.longitude)" }
            .joined(separator: "+to:")
        
        // Construct Google Maps URL
        let googleMapsURLString = "http://maps.google.com/maps?daddr=\(waypoints)+to:\(destination.latitude),\(destination.longitude)"
        
        // Create URL object
        guard let url = URL(string: googleMapsURLString) else {
            showAlert(title: "Invalid URL", message: "URL cannnot be read")
            return nil
        }
        
        // Check if Google Maps app can handle the URL scheme, if not open in browser
        if UIApplication.shared.canOpenURL(url) {
            return url
        } else {
            // Fallback URL in case the Google Maps app is not available
            let fallbackURLString = "https://maps.google.com/?daddr=\(waypoints)+to:\(destination.latitude),\(destination.longitude)"
            return URL(string: fallbackURLString)
        }
    }
    
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(sendLocationUpdate), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }
    
    @objc func imageTapped() {
        routeToScheduled()
    }
    
    func routeToScheduled() {
        let scheduledVC = ScheduledViewController()
        scheduledVC.modalPresentationStyle = .overFullScreen
        scheduledVC.delegate = self
        self.present(scheduledVC, animated: false, completion: nil)
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
        self.postAll() { result in
            switch result {
            case .success(let responseModel):
                if responseModel.success == false {
                    self.showBasicModal(title: "Info", message: "This job is already expired.")
                }
                if responseModel.success, let data = responseModel.data {
                    self.tripsData = data
                    let startpoint = data.points?.first?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
                    let endpoint = data.points?.last?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
                    self.startPoinnt.text = startpoint?.capitalized
                    self.endPoint.text = endpoint?.capitalized
                    if data.codeName?.lowercased() == "adhoc" {
                        self.finishButton.isHidden = false
                    }
                    self.goTime.text = (data.points?[0].time ?? "") + " to " + (data.points?[1].time ?? "")
                } else {
                    print("All trips data is empty.")
                }
            case .failure(let error):
                print("failed post all job")
            }
        }
        startTimer()
        routeToScheduled()
        setupUI()
    }
    
    func setupMaps() {
        guard let location = currentLocation else {
            print("No location available")
            return
        }
        DispatchQueue.main.async {
            let camera = GMSCameraPosition.camera(
                withLatitude:  location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 12.0
            )
            self.mapView.camera = camera
            print(">>>> location zoom : \(camera.zoom)")
        }
        
        self.mapView.bringSubviewToFront(notificationIcon)
        self.mapView.bringSubviewToFront(markerImageView)
        
        let points = tripsData?.points ?? [Point]()
        let paths = tripsData?.path ?? [Path]()
        let path = GMSMutablePath()
        for point in paths {
            let coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            path.add(coordinate)
        }
        // Create a polyline with the path
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .blue
        polyline.strokeWidth = 5.0
        polyline.map = mapView
        
        
        // Add markers for each point
        for point in points {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            marker.title = point.pointName
            marker.snippet = "Passengers: \(point.numberOfPassengers)"
            
            let iconName: String
            switch point.type {
            case 0:
                iconName = "green_marker" // Green icon for type 0
            case 1:
                iconName = "blue_marker"  // Blue icon for type 1
            default:
                iconName = "" // Default icon if needed
            }
            
            if tripsData?.codeName?.lowercased() == "adhoc" {
                let markerView = CustomMarkerView(iconName: iconName, numberOfPassengers: "")
                if let markerImage = markerView.asImage() {
                    marker.icon = markerImage
                }
                
                marker.map = mapView
            } else {
                let markerView = CustomMarkerView(iconName: iconName, numberOfPassengers: String(point.numberOfPassengers))
                if let markerImage = markerView.asImage() {
                    marker.icon = markerImage
                }
                
                marker.map = mapView
            }
        }
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let vc = SettingViewController()
        vc.userData = userData
        navigationController?.pushViewController(vc, animated: false)
    }
    @objc func sendLocationUpdate() {
        guard let location = currentLocation else {
            print("No location available")
            return
        }
        
        // Prepare the data to be sent
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let altitude = location.altitude
        let accuracy = location.horizontalAccuracy
        let speed = location.speed
        let date = ISO8601DateFormatter().string(from: Date()) // Use ISO 8601 format for the date
        
        // Call the function to send data
        sendLocationData(latitude: latitude, longitude: longitude, altitude: altitude, accuracy: accuracy, speed: speed, date: date)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Invalidate the timer when the view is dismissed
        timer?.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Retrieve current location only for the first time
        if !isLocationRetrieved {
            locationManager.startUpdatingLocation()
        }
    }
    @IBAction func finishTripTapped(_ sender: Any) {
        self.endTrips(accessCode: tripsData?.adhoc?.busCharterID ?? "") { result in
            switch result {
            case .success(let responseModel):
                if responseModel.success == false {
                    self.showBasicModal(title: "Info", message: "The Services is not response")
                }
                if responseModel.success, let data = responseModel.data {
                    self.postAll() { result in
                        switch result {
                        case .success(let responseModel):
                            if responseModel.success == false {
                                self.showBasicModal(title: "Info", message: "This job is already expired")
                            }
                            if responseModel.success, let data = responseModel.data {
                                self.tripsData = data
                                let startpoint = data.points?.first?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
                                let endpoint = data.points?.last?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
                                
                                self.startPoinnt.text = startpoint?.capitalized
                                self.endPoint.text = endpoint?.capitalized
                                self.goTime.text = (data.points?.first?.time ?? "") + " to " + (data.points?.last?.time ?? "")
                                self.setupUI()
                            } else {
                                print("All trips data is empty.")
                            }
                        case .failure(let error):
                            print("failed post all job")
                        }
                    }
                } else {
                    self.showBasicModal(title: "Error", message: responseModel.data?.message ?? "")
                }
            case .failure(let error):
                self.showBasicModal(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
}

extension HomeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let camera = GMSCameraPosition.camera(
            withLatitude: position.target.latitude,
            longitude: position.target.longitude,
            zoom: position.zoom)
        mapView.camera = camera
        print(">>>> location zoom : \(position.zoom)")
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print(">>>> location zoom : \(position.zoom)")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print(">>>> location zoom : \(mapView.camera.zoom)")
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        if let location = locations.first, !isLocationRetrieved {
            // Stop updating location after the first fetch
            locationManager.stopUpdatingLocation()
            isLocationRetrieved = true
            setupMaps()
        }
        DispatchQueue.main.async {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: self.currentLocation?.coordinate.latitude ?? 0.0,
                longitude: self.currentLocation?.coordinate.longitude ?? 0.0)
            marker.icon = UIImage(systemName: "bus.fill")
            marker.map = self.mapView
        }
    }
    
    // Handle location authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            // Handle permission denial
            print("Location permission denied")
        }
    }
    
    // Handle errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fetching location: \(error.localizedDescription)")
    }
}

extension HomeViewController: ScheduledViewControllerProtocol {
    func didDismissView() {
        self.postAll() { result in
            switch result {
            case .success(let responseModel):
                if responseModel.success == false {
                    self.showBasicModal(title: "Info", message: "This job is already expired.")
                }
                if responseModel.success, let data = responseModel.data {
                    self.tripsData = data
                    let startpoint = data.points?.first?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
                    let endpoint = data.points?.last?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
                    self.startPoinnt.text = startpoint?.capitalized
                    self.endPoint.text = endpoint?.capitalized
                    if data.codeName?.lowercased() == "adhoc" {
                        self.finishButton.isHidden = false
                    }
                    self.goTime.text = (data.points?[0].time ?? "") + " to " + (data.points?[1].time ?? "")
                    self.setupUI()
                } else {
                    print("All trips data is empty.")
                }
            case .failure(let error):
                print("failed post all job")
            }
        }
    }
}
