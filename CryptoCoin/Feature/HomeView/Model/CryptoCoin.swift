//
//  CryptoCoin.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

import Foundation

struct CryptoCoin: Codable, Hashable {
  let name: String
  let symbol: String
  let type: String
  let isActive: Bool
  let isNew: Bool
  
  enum CodingKeys: String, CodingKey {
    case name, symbol, type
    case isActive = "is_active"
    case isNew = "is_new"
  }
}
