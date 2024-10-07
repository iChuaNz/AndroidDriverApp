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
    
    @IBOutlet weak var titleComponent: UILabel!
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
    var lastUpdatedHeading: CLLocationDirection = 0 // To track the last heading update
    let headingThreshold: CLLocationDirection = 25
    var isAutoUpdatingHeading = true
    let marker = GMSMarker()
    var markers: [GMSMarker] = []
    let path = GMSMutablePath()
    let customButton = UIButton(type: .custom)
    var backgroundTimestamp: Date?
    var isOn = true
    var timeElapsed: TimeInterval = 0
    var userData: UserData?
    var tripsData: TripsData?
    var otherTripsData: AllTripsData?
    let locationManager = CLLocationManager()
    var timer: Timer?
    var currentLocation: CLLocation?
    @IBOutlet weak var calendarImage: UIImageView!
    var isLocationRetrieved = false
    var isCurrenntTrip = true
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    let pathData: [[String: Double]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        setupRighButtonNav()
        
        locationManager.startUpdatingLocation()
        if isCurrenntTrip == true {
            self.postAll() { result in
                switch result {
                case .success(let responseModel):
                    if responseModel.success == false {
                        self.showBasicModal(title: "Info", message: "This job is already expired")
                        self.setupUI()
                    }
                    if responseModel.success, let data = responseModel.data {
                        self.tripsData = data
                        self.setupUI()
                    } else {
                        print("All trips data is empty.")
                    }
                case .failure(let error):
                    print("failed post all job")
                }
            }
        } else {
            self.setupOtherTrip(otherTripsData: otherTripsData)
        }
        
        startTimer()
        routeToScheduled()
        containerScheduledView.layer.cornerRadius = 16
        containerScheduledView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top left and top right corners only
        containerScheduledView.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        calendarImage.isUserInteractionEnabled = true
        calendarImage.addGestureRecognizer(tapGestureRecognizer)
        let tapToMaps = UITapGestureRecognizer(target: self, action: #selector(routeToGmaps))
        notificationIcon.isUserInteractionEnabled = true
        notificationIcon.addGestureRecognizer(tapToMaps)
        
        if isAutoUpdatingHeading {
            locationManager.startUpdatingHeading()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopLocationUpdates), name: Notification.Name("UserLoggedOut"), object: nil)
    }
    
    deinit {
           NotificationCenter.default.removeObserver(self, name: Notification.Name("UserLoggedOut"), object: nil)
       }
    
    @objc func stopLocationUpdates() {
          // Invalidate timer and stop location updates
          timer?.invalidate()
          locationManager.stopUpdatingLocation()
      }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
        // Retrieve current location only for the first time
        if !isLocationRetrieved {
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupOtherTrip(otherTripsData: AllTripsData?) {
        self.titleComponent.text = "Viewing Trip"
        self.finishButton.isHidden = false
        self.finishButton.setTitle("Reload Trip", for: .normal)
        self.vehicleNumber.text = "Vehicle No: " + (otherTripsData?.vehicleNo ?? "-")
        let startpoint = otherTripsData?.points?.first?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
        let endpoint = otherTripsData?.points?.last?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
        self.startPoinnt.text = startpoint?.capitalized
        self.endPoint.text = endpoint?.capitalized
        self.goTime.text = (otherTripsData?.points?.first?.time ?? "") + " to " + (otherTripsData?.points?.last?.time ?? "")
        
        let points = otherTripsData?.points ?? [Point]()
        let paths = otherTripsData?.path ?? [Path]()
        
        for point in points {
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
            let markerPoint = GMSMarker()
            markerPoint.position = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            markerPoint.title = point.pointName
            markerPoint.snippet = "Passengers: \(point.numberOfPassengers)"
            
            let iconName: String
            switch point.type {
            case 0:
                iconName = "green_marker" // Green icon for type 0
            case 1:
                iconName = "blue_marker"  // Blue icon for type 1
            default:
                iconName = "" // Default icon if needed
            }
            
            if otherTripsData?.codeName?.lowercased() == "adhoc" {
                let markerView = CustomMarkerView(iconName: iconName, numberOfPassengers: "", title: point.time)
                if let markerImage = markerView.asImage() {
                    markerPoint.icon = markerImage
                    markerPoint.map = mapView
                    markers.append(markerPoint)
                }
            } else {
                let markerView = CustomMarkerView(iconName: iconName, numberOfPassengers: String(point.numberOfPassengers), title: point.time)
                if let markerImage = markerView.asImage() {
                    markerPoint.icon = markerImage
                    markerPoint.map = mapView
                    markers.append(markerPoint)
                }
            }
        }
        
        if otherTripsData?.codeName?.lowercased() == "adhoc" {
            if otherTripsData?.adhoc?.serviceType?.lowercased() == "disposal" {
                if let codeName = otherTripsData?.codeName,
                   let adhoc = otherTripsData?.adhoc {
                    let duration = adhoc.duration ?? ""
                    let serviceType = adhoc.serviceType ?? ""
                    self.destinationTitleTripLabel.text = (otherTripsData?.codeName ?? "") + " (\(duration)h \(serviceType))"
                } else {
                    self.destinationTitleTripLabel.text = (otherTripsData?.codeName ?? "") + " (\(otherTripsData?.adhoc?.serviceType ?? ""))"
                }
            } else {
                if self.otherTripsData?.adhoc?.serviceType?.isEmpty == true {
                    self.destinationTitleTripLabel.text = (otherTripsData?.codeName ?? "")
                } else {
                    self.destinationTitleTripLabel.text = (otherTripsData?.codeName ?? "") + " (\(otherTripsData?.adhoc?.serviceType ?? ""))"
                }
            }
        } else {
            guard let serviceType = self.otherTripsData?.adhoc?.serviceType else {
                self.destinationTitleTripLabel.text = (otherTripsData?.codeName ?? "")
                return
            }
            if self.otherTripsData?.adhoc?.serviceType?.isEmpty == true {
                self.destinationTitleTripLabel.text = (otherTripsData?.codeName ?? "")
            } else {
                self.destinationTitleTripLabel.text = (otherTripsData?.codeName ?? "") + " (\(otherTripsData?.adhoc?.serviceType ?? "-"))"
            }
        }
    }
    
    func setupRighButtonNav() {
        customButton.setTitle("CAMERA-AUTO", for: .normal)
        customButton.setTitleColor(.white, for: .normal)
        customButton.titleLabel?.font =  UIFont.systemFont(ofSize: 12)
        customButton.titleLabel?.textAlignment = .center
        customButton.backgroundColor = .systemBlue
        customButton.frame = CGRect(x: 0, y: 0, width: 140, height: 40)
        customButton.addTarget(self, action: #selector(tappedCamera), for: .touchUpInside)
        
        // Create a UIBarButtonItem using the custom button
        let rightBarButton = UIBarButtonItem(customView: customButton)
        
        // Set the custom view as the right bar button item
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupUI() {
        self.titleComponent.text = "Current Trip"
        self.finishButton.setTitle("End Trip", for: .normal)
        self.vehicleNumber.text = "Vehicle No: " + (tripsData?.vehicleNo ?? "-")
        let startpoint = tripsData?.points?.first?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
        let endpoint = tripsData?.points?.last?.pointName.lowercased().replacingOccurrences(of: "bus stop opp", with: "")
        self.startPoinnt.text = startpoint?.capitalized
        self.endPoint.text = endpoint?.capitalized
        self.goTime.text = (tripsData?.points?.first?.time ?? "") + " to " + (tripsData?.points?.last?.time ?? "")
        
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
            if tripsData?.codeName?.lowercased() == "sgk" {
                self.finishButton.isHidden = false
            } else {
                self.finishButton.isHidden = true
            }
            
            if self.tripsData?.adhoc?.serviceType?.isEmpty == true {
                self.destinationTitleTripLabel.text = (tripsData?.codeName ?? "")
            } else {
                self.destinationTitleTripLabel.text = (tripsData?.codeName ?? "") + " (\(tripsData?.adhoc?.serviceType ?? "-"))"
            }
        }
        setupMaps()
    }
    
    @objc func routeToGmaps(){
        if isCurrenntTrip == true {
            if let url = generateGoogleMapsURL(from: tripsData?.points ?? [Point]()) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            if let url = generateGoogleMapsURL(from: otherTripsData?.points ?? [Point]()) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    @objc func tappedCamera(){
        isOn.toggle()
        isAutoUpdatingHeading.toggle()
        
        if isAutoUpdatingHeading {
            locationManager.startUpdatingHeading()
        } else {
            locationManager.stopUpdatingHeading()
        }
        
        if isOn {
            customButton.setTitle("CAMERA-AUTO", for: .normal)
            customButton.setTitleColor(.white, for: .normal)
            customButton.titleLabel?.font =  UIFont.systemFont(ofSize: 12)
            customButton.backgroundColor = .systemBlue
        } else {
            customButton.setTitle("CAMERA-MANUAL", for: .normal)
            customButton.setTitleColor(.white, for: .normal)
            customButton.titleLabel?.font =  UIFont.systemFont(ofSize: 12)
            customButton.backgroundColor = .gray
        }
    }
    
    func generateGoogleMapsURL(from points: [Point]) -> URL? {
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
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "LocationUpdate") {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                  self?.sendLocationUpdate()
              }
//        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(sendLocationUpdate), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }
    
    // Called when the app is about to go to the background
    @objc func appWillResignActive() {
        backgroundTimestamp = Date() // Save the current timestamp
        timer?.invalidate() // Invalidate the timer while in the background
    }
    
    // Called when the app returns to the foreground
    @objc func appDidBecomeActive() {
        if let backgroundTimestamp = backgroundTimestamp {
            let timeInBackground = Date().timeIntervalSince(backgroundTimestamp)
            timeElapsed += timeInBackground // Add the background time to the timer
        }
        startTimer() // Restart the timer
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
        if isCurrenntTrip == true {
            self.postAll() { result in
                switch result {
                case .success(let responseModel):
                    if responseModel.success == false {
                        self.showBasicModal(title: "Info", message: "This job is already expired.")
                        self.setupUI()
                    }
                    if responseModel.success, let data = responseModel.data {
                        self.tripsData = data
                        self.setupUI()
                    } else {
                        print("All trips data is empty.")
                    }
                case .failure(let error):
                    print("failed post all job")
                }
            }
        } else {
            self.setupOtherTrip(otherTripsData: otherTripsData)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        calendarImage.isUserInteractionEnabled = true
        calendarImage.addGestureRecognizer(tapGestureRecognizer)
        let tapToMaps = UITapGestureRecognizer(target: self, action: #selector(routeToGmaps))
        notificationIcon.isUserInteractionEnabled = true
        notificationIcon.addGestureRecognizer(tapToMaps)
        
        startTimer()
    }
    
    func resetData() {
        self.tripsData = nil
        self.otherTripsData = nil
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
            self.marker.position = CLLocationCoordinate2D(
                latitude: self.currentLocation?.coordinate.latitude ?? 0.0,
                longitude: self.currentLocation?.coordinate.longitude ?? 0.0)
            self.marker.icon = UIImage(systemName: "bus.fill")
            self.marker.map = self.mapView
            self.mapView.camera = camera
            print(">>>> location zoom : \(camera.zoom)")
        }
        
        self.mapView.bringSubviewToFront(notificationIcon)
        self.mapView.bringSubviewToFront(markerImageView)
        
        let points: [Point]
        let paths: [Path]
        
        points = tripsData?.points ?? [Point]()
        paths = tripsData?.path ?? [Path]()
        
        for point in paths {
            let coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            path.add(coordinate)
        }
        // Create a polyline with the path
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .blue
        polyline.strokeWidth = 5.0
        polyline.map = mapView
        
        for point in points {
            let markerPoint = GMSMarker()
            markerPoint.position = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            markerPoint.title = point.pointName
            markerPoint.snippet = "Passengers: \(point.numberOfPassengers)"
            
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
                let markerView = CustomMarkerView(iconName: iconName, numberOfPassengers: "", title: point.time)
                if let markerImage = markerView.asImage() {
                    markerPoint.icon = markerImage
                    markerPoint.map = mapView
                    markers.append(markerPoint)
                }
            } else {
                let markerView = CustomMarkerView(iconName: iconName, numberOfPassengers: String(point.numberOfPassengers), title: point.time)
                if let markerImage = markerView.asImage() {
                    markerPoint.icon = markerImage
                    markerPoint.map = mapView
                    markers.append(markerPoint)
                }
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
        print(">>>> GPS")
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
    // Function to clear only the points in the path
    func clearPathPoints() {
        for item in markers {
            item.map = nil
        }
        markers.removeAll()
        mapView.clear()
        path.removeAllCoordinates()
    }
    @IBAction func finishTripTapped(_ sender: Any) {
        if isCurrenntTrip == true {
            self.endTrips(accessCode: tripsData?.routeID ?? 0) { result in
                switch result {
                case .success(let responseModel):
                    if responseModel.success == false {
                        self.showBasicModal(title: "Info", message: "The Services is not response")
                    } else {
                        self.setupUI()
                    }
                case .failure(let error):
                    self.showBasicModal(title: "Error", message: error.localizedDescription)
                }
            }
        } else {
            isCurrenntTrip.toggle()
            self.clearPathPoints()
            self.postAll() { result in
                switch result {
                case .success(let responseModel):
                    if responseModel.success == false {
                        self.showBasicModal(title: "Info", message: "This job is already expired.")
                    }
                    if responseModel.success, let data = responseModel.data {
                        self.tripsData = data
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
}

fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
    return UIBackgroundTaskIdentifier(rawValue: input)
}
