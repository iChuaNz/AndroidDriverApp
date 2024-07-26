//
//  Services.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 24/07/24.
//

import Foundation
import UIKit

protocol Service {
    func request(endpoint: Endpoint, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

class NetworkService: Service {
    func request(endpoint: Endpoint,completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        let task = createTask(url: endpoint.url, completion: completion)
        task.resume()
    }
    
    private func createTask(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        return URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { completion(data, response, error) }
        }
    }
}
