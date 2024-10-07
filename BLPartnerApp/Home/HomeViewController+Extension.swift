//
//  HomeViewController+Extension.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 02/09/24.
//

import Foundation
import GoogleMaps
import GoogleUtilities

extension HomeViewController {
    func postAll(completion: @escaping (Result<ResponseTrips, Error>) -> Void) {
        guard let url = URL(string: "https://bustracker.azurewebsites.net/api/2/Jobs/Trips") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(userData?.token ?? "", forHTTPHeaderField: "token")

        
        // Create a URLSession
        let session = URLSession.shared
        BasicAlert.shared.showLoading(self.view)
        // Create the data task
        let task = session.dataTask(with: request) { data, response, error in
            // Handle the response
            if let error = error {
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let responseError = NSError(domain: "InvalidResponse", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    completion(.failure(responseError))
                }
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let responseModel = try decoder.decode(ResponseTrips.self, from: data)
                    DispatchQueue.main.async {
                        BasicAlert.shared.dismiss()
                        completion(.success(responseModel))
                    }
                } catch {
                    DispatchQueue.main.async {
                        BasicAlert.shared.dismiss()
                        completion(.failure(error))
                    }
                }
            } else {
                let parseError = NSError(domain: "DataParseError", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    completion(.failure(parseError))
                }
            }
        }
        task.resume()
    }
    
    func endTrips(accessCode: Int, completion: @escaping (Result<ResponseLogin, Error>) -> Void) {
        guard let url = URL(string: "https://bustracker.azurewebsites.net/api/2/Jobs/EndTripRoute") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(userData?.token ?? "", forHTTPHeaderField: "token")
        
        let body: [String: Any] = [
            "data": [
                "BusCharterId": accessCode
            ]
        ]
            
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else { return }
        request.httpBody = httpBody
    
        let session = URLSession.shared
        BasicAlert.shared.showLoading(self.view)
        // Create the data task
        let task = session.dataTask(with: request) { data, response, error in
            // Handle the response
            if let error = error {
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let responseError = NSError(domain: "InvalidResponse", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    completion(.failure(responseError))
                }
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let responseModel = try decoder.decode(ResponseLogin.self, from: data)
                    DispatchQueue.main.async {
                        BasicAlert.shared.dismiss()
                        completion(.success(responseModel))
                    }
                } catch {
                    DispatchQueue.main.async {
                        BasicAlert.shared.dismiss()
                        completion(.failure(error))
                    }
                }
            } else {
                let parseError = NSError(domain: "DataParseError", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    completion(.failure(parseError))
                }
            }
        }
        task.resume()
    }
}


extension HomeViewController: ScheduledViewControllerProtocol {
    func didDismissWithObject(isCurrentTrip: Bool, trip: AllTripsData) {
        self.isCurrenntTrip = isCurrentTrip
        self.otherTripsData = trip
        self.clearPathPoints()
        if isCurrenntTrip == true {
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
        }  else {
            self.setupOtherTrip(otherTripsData: trip)
        }
    }
    
    func didDismissView() {
        self.clearPathPoints()
        if isCurrenntTrip == true {
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
        } else {
            self.setupOtherTrip(otherTripsData: otherTripsData)
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
        print(">>>> idle zoom : \(position.zoom)")
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print(">>>> did change zoom : \(position.zoom)")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print(">>>> will move zoom : \(mapView.camera.zoom)")
    }
}
