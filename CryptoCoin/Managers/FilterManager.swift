//
//  FilterManager.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

struct FilterCriteria {
  var isActive: Bool?
  var type: String?
  var isNew: Bool?
}

protocol FilterManagerProtocol {
  func filter(coins: [CryptoCoin], criteria: FilterCriteria) -> [CryptoCoin]
}

class FilterManager: FilterManagerProtocol {
  func filter(coins: [CryptoCoin], criteria: FilterCriteria) -> [CryptoCoin] {
    return coins.filter { coin in
      let isActiveMatch = criteria.isActive == nil || coin.isActive == criteria.isActive
      let typeMatch = criteria.type == nil || coin.type == criteria.type
      let isNewMatch = criteria.isNew == nil || coin.isNew == criteria.isNew
      return isActiveMatch && typeMatch && isNewMatch
    }
  }
}
