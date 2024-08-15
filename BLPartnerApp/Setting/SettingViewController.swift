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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var userIdTitle: UILabel!
    @IBOutlet weak var userIdValue: UILabel!
    @IBOutlet weak var versionTitle: UILabel!
    @IBOutlet weak var versionValue: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var buildNumberTitleLabel: UILabel!
    @IBOutlet weak var buildNumberValueLabel: UILabel!
    
    var userData: UserData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
        getProfile() { result in
            switch result {
            case .success(let responseString):
                print("=== Response data: \(responseString)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func routeToLogin() {
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func setupUI () {
        self.navigationItem.title = "Profile"
        self.userIdValue.text = userData?.userName ?? ""
        versionValue.text = (Bundle.main.releaseVersionNumber ?? "")
        buildNumberValueLabel.text = (Bundle.main.buildVersionNumber ?? "")
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        logout() { result in
            switch result {
            case .success(let responseString):
                self.routeToLogin()
                print("=== Response data: \(responseString)")
            case .failure(let error):
                self.routeToLogin()
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension SettingViewController {
    func getProfile(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://bustrackerstaging.azurewebsites.net/api/2/vendor/profile") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters: [String: Any] = [
            "deviceToken": UserDefaults.standard.string(forKey: "FCMToken") ?? ""
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
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    completion(.success(responseString))
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
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://bustrackerstaging.azurewebsites.net/api/2/user/logout") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters: [String: Any] = [
            "deviceToken": UserDefaults.standard.string(forKey: "FCMToken") ?? ""
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
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    BasicAlert.shared.dismiss()
                    completion(.success(responseString))
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
