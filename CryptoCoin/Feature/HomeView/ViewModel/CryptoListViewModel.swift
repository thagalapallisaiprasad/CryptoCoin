//
//  CryptoListViewModel.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

import Foundation

@MainActor
class CryptoListViewModel {
  private let service: CryptoServiceProtocol
  private let filterManager: FilterManagerProtocol
  private(set) var coins: [CryptoCoin] = []
  private(set) var filteredCoins: [CryptoCoin] = []
  
  var filterCriteria = FilterCriteria()
  var didUpdate: (() -> Void)?
  
  init(service: CryptoServiceProtocol = CryptoService(), filter: FilterManagerProtocol = FilterManager()) {
    self.service = service
    self.filterManager = filter
  }
  
  func fetchCoins() {
    service.fetchCryptoCoins { [weak self] (result: Result<[CryptoCoin], any Error>) in
      switch result {
        case .success(let coins):
          DispatchQueue.main.async { [weak self] in
            self?.coins = coins
            self?.applyFilters()
          }
        case .failure(let error):
          print("Error fetching coins: \(error)")
      }
    }
  }
  
  func applyFilters() {
    filteredCoins = filterManager.filter(coins: coins, criteria: filterCriteria)
    didUpdate?()
  }
  
  func toggleActiveFilter() {
    filterCriteria.isActive = !(filterCriteria.isActive ?? false)
    applyFilters()
  }
  
  func toggleInactiveFilter() {
    filterCriteria.isActive = filterCriteria.isActive == nil || filterCriteria.isActive == true ? false : nil
    applyFilters()
  }
  
  func toggleTokensFilter() {
    filterCriteria.type = filterCriteria.type == "Token" ? nil : "Token"
    applyFilters()
  }
  
  func toggleCoinsFilter() {
    filterCriteria.type = filterCriteria.type == "Coin" ? nil : "Coin"
    applyFilters()
  }
  
  func toggleNewCoinsFilter() {
    filterCriteria.isNew = filterCriteria.isNew == true ? nil : true
    applyFilters()
  }
  
  func clearFilters() {
    filterCriteria = FilterCriteria()
    applyFilters()
  }
  
  func searchCoins(query: String) {
    if query.isEmpty {
      filteredCoins = coins
    } else {
      filteredCoins = coins.filter { coin in
        coin.name.lowercased().contains(query.lowercased()) ||
        coin.symbol.lowercased().contains(query.lowercased())
      }
    }
    didUpdate?()
  }
}
