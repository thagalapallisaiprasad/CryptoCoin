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
  private let databaseManager: DatabaseManagerProtocol
  private(set) var coins: [CryptoCoin] = []
  private(set) var filteredCoins: [CryptoCoin] = []
  
  var filterCriteria = FilterCriteria()
  var didUpdate: (() -> Void)?
  
  init(service: CryptoServiceProtocol = CryptoService(), database: DatabaseManagerProtocol = DatabaseManager()) {
    self.service = service
    self.databaseManager = database
  }
  
  func fetchCoins() {
    if let mockService = service as? MockCryptoService {
      // Use mock data if the service is MockCryptoService
      self.coins = mockService.mockCoins
    } else {
      if let coins = fetchCoinsFromCoreData(), coins.count > 0 {
        self.coins = coins
        self.applyFilters()
      } else {
        service.fetchCryptoCoins { [weak self] (result: Result<[CryptoCoin], any Error>) in
          switch result {
            case .success(let coins):
              DispatchQueue.main.async { [weak self] in
                self?.coins = coins
                self?.storeCoinsInDatabase(coins)
                self?.applyFilters()
              }
            case .failure(let error):
              print("Error fetching coins: \(error)")
          }
        }
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
  
  func clearFilters() {
    filterCriteria = FilterCriteria()
    applyFilters()
  }
  
  // Store fetched coins in Core Data
  private func storeCoinsInDatabase(_ coins: [CryptoCoin]) {
    coins.forEach { coin in
      do {
        try databaseManager.saveCryptoCoin(coin)
      } catch {
        print("Failed to save coin: \(error)")
      }
    }
  }
  
  // Fetch coins from Core Data (if API fails or no network)
  func fetchCoinsFromCoreData() -> [CryptoCoin]? {
    do {
      return try databaseManager.fetchCryptoCoins()
    } catch {
      print("Failed to fetch coins from Core Data: \(error)")
      return nil
    }
  }
  
}
