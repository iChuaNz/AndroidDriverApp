//
//  ResponseLogin.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 02/08/24.
//

import Foundation

struct ResponseLogin: Codable {
    let success: Bool
    let data: UserData?
    let error: String?
}

struct UserData: Codable {
    let role: String
    let message: String
    let vehicleNo: String?
    let success: Bool
    let token: String
    let userName: String
}
