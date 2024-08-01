//
//  BasicUIState.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 01/08/24.
//

import Foundation


enum BasicUIState {
    case loading
    case success(String)
    case failure(String)
    case warning(String)
    case close
}
