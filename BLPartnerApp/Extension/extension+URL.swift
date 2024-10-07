//
//  extension+URL.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 24/07/24.
//

import Foundation

extension URL {
    static func makeForEndpoint(_ endpoint: String) -> URL {
        #if DEBUG
        URL(string: "https://bustrackerstaging.azurewebsites.net/\(endpoint)")!
        #else
        URL(string: "https://bustracker.azurewebsites.net/\(endpoint)")!
        #endif
    }
}
