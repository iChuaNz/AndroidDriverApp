//
//  ResponseJobs.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 16/08/24.
//

import Foundation

// MARK: - ResponseJobs
struct ResponseJobs: Codable {
    let success: Bool
    let data: [JobsData]?
    let error: JSONNull?
}

// MARK: - DataClass
struct JobsData: Codable {
    let totalBoarded: Int
    let points: [Point]
    let routeID: Int
    let vehicleNo: String?
    let message: String
    let schoolBus, externalNFC: Bool
    let passengers: [Passenger]
    let path: [Path] = []
    let internalNFC: Bool
    let codeName: String
    let totalAligned: Int
    let adhoc: Adhoc
    let totalPassenger: Int
    let fourDigitCode, serviceName: String

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

// MARK: - Passenger
struct Passenger: Codable {
    let gender, picURL: String
    let smsNOK: Bool
    let ezlinkCanID, bordedOrAligned: String?
    let nokName, nokContact, name, nokRelationship: String

    enum CodingKeys: String, CodingKey {
        case gender
        case picURL = "picUrl"
        case smsNOK
        case ezlinkCanID = "ezlinkCanId"
        case bordedOrAligned, nokName, nokContact, name, nokRelationship
    }
}

// MARK: - Path
struct Path: Codable {
    let longitude, latitude: Double
}

// MARK: - Point
struct Point: Codable {
    let time: String
    let numberOfPassengers: Int
    let pointName: String
    let latitude, longitude: Double
    let type: Int
}
