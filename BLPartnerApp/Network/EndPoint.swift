//
//  EndPoint.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 24/07/24.
//

import Foundation

enum Endpoint {
    case getLogin(String, String)
    
    
    var apiKey: String {
        return "76fa09707c5f4efbb7ad898dda51465b"
    }
    
    var url: URL {
        switch self {
        case .getLogin(let phonenumber, let passcode):
            return .makeForEndpoint("api/2/user/login")
        }
    }
}
