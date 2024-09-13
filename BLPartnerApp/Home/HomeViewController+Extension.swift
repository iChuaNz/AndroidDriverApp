//
//  HomeViewController+Extension.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 02/09/24.
//

import Foundation

extension HomeViewController {
    func postAll(completion: @escaping (Result<ResponseTrips, Error>) -> Void) {
        guard let url = URL(string: "https://bustrackerstaging.azurewebsites.net/api/2/Jobs/Trips") else {
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
    
    func endTrips(accessCode: String, completion: @escaping (Result<ResponseLogin, Error>) -> Void) {
        guard let url = URL(string: "https://bustrackerstaging.azurewebsites.net/api/2/Jobs/EndRouteTrip/") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "BusCharterId": accessCode,
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
    
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
