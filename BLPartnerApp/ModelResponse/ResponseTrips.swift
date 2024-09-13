//
//  ResponseTrips.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 30/08/24.
//

import Foundation

// MARK: - ResponseTrips
struct ResponseTrips: Codable {
    let success: Bool
    let data: TripsData?
    let error: String?
}

// MARK: - DataClass
struct TripsData: Codable {
    let totalBoarded: Int?
    let points: [Point]?
    let routeID: Int?
    let vehicleNo: String?
    let message: String?
    let schoolBus, externalNFC: Bool?
    let passengers: [Passenger]?
    let path: [Path]?
    let internalNFC: Bool?
    let codeName: String?
    let totalAligned: Int?
    let adhoc: Adhoc?
    let totalPassenger: Int?
    let fourDigitCode, serviceName: String?

    enum CodingKeys: String, CodingKey {
        case totalBoarded, points
        case routeID = "routeId"
        case vehicleNo, message, schoolBus
        case externalNFC = "externalNfc"
        case passengers, path
        case internalNFC = "internalNfc"
        case codeName, totalAligned, adhoc, totalPassenger, fourDigitCode, serviceName
    }
}
