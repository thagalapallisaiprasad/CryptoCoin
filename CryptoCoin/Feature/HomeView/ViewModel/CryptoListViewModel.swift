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
    // Filters applied to coins
    filteredCoins = coins.filter {
      ($0.isActive == filterCriteria.isActive || filterCriteria.isActive == nil) &&
      ($0.isNew == filterCriteria.isNew || filterCriteria.isNew == nil) &&
      ($0.type == filterCriteria.type || filterCriteria.type == nil)
    }
    
    // Notify any observers to update the UI
    didUpdate?()
  }
  
  func updateFilter(_ criteria: FilterCriteria) {
    filterCriteria = criteria
    applyFilters()
  }
  
  func searchCoins(query: String) {
    filteredCoins = query.isEmpty ? coins : coins.filter {
      $0.name.localizedCaseInsensitiveContains(query) ||
      $0.symbol.localizedCaseInsensitiveContains(query)
    }
    didUpdate?()
  }
  
  func clearFilters() {
    filterCriteria = FilterCriteria()
    applyFilters()
  }
}
