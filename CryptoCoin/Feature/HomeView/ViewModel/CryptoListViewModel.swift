//
//  CryptoListViewModel.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

import Foundation

@MainActor
class CryptoListViewModel {
  private let networkProtocol: NetworkProtocol
  private let databaseManager: DatabaseManagerProtocol
  private(set) var coins: [CryptoCoin] = []
  private(set) var filteredCoins: [CryptoCoin] = []
  
  var filterCriteria = FilterCriteria()
  var didUpdate: (() -> Void)?
  
  init(networkProtocol: NetworkProtocol = URLSession.shared, database: DatabaseManagerProtocol = DatabaseManager()) {
    self.networkProtocol = networkProtocol
    self.databaseManager = database
  }
  
  func fetchCoins() {
    // Check if coins exist in local database first
    if let coins = fetchCoinsFromCoreData(), coins.count > 0 {
      self.coins = coins
      didUpdate?()
    } else {
      // Fetch from the network if no local data exists
      let url = URL(string: Constants.API.baseURL)!
      networkProtocol.sessionDataTask(with: url) { [weak self] (result: Result<[CryptoCoin], Error>) in
        switch result {
          case .success(let coins):
            // Update UI and database when data is fetched
            DispatchQueue.main.async { [weak self] in
              self?.coins = coins
              self?.storeCoinsInDatabase(coins)
              self?.didUpdate?()
            }
          case .failure(let error):
            // Handle failure to fetch coins
            print("Error fetching coins: \(error)")
        }
      }
    }
  }
  
  func updateFilters(criteria: FilterCriteria, isSelected: Bool) {
    
    var result: [CryptoCoin] = filteredCoins
    
    if let isActive = criteria.isActive, let type = criteria.type {
      if type == "coin" || type == "token" && isActive {
        if isSelected {
          let filteredCoins = coins.filter { $0.isActive == isActive && $0.type == type }
          result.append(contentsOf: filteredCoins)
        } else {
          result.removeAll { $0.isActive == isActive && $0.type == type }
        }
      }
      if (type == "coin" || type == "token") && isActive == false {
        if isSelected {
          let filteredCoins = coins.filter { $0.isActive == false && $0.type == type }
          result.append(contentsOf: filteredCoins)
        } else {
          result.removeAll{$0.isActive == false && $0.type == type}
        }
      }
    } else if let isNew = criteria.isNew, criteria.type == "coin" {
      if isSelected {
        let newCoins = coins.filter { $0.isNew == isNew && $0.type == "coin" }
        result.append(contentsOf: newCoins)
      } else {
        result.removeAll { $0.isNew == isNew && $0.type == "coin" }
      }
    } else if let type = criteria.type {
      if isSelected {
        let filteredByType = coins.filter { $0.type == type }
        result.append(contentsOf: filteredByType)
      } else {
        result.removeAll { $0.type == type }
      }
    }
    
    filteredCoins = Array(Set(result))
    didUpdate?()
  }
  
  func removeAllFilter() {
    filteredCoins.removeAll()
  }
  
  func search(query: String) {
    filteredCoins = coins.filter { item in
      item.name.lowercased().contains(query.lowercased()) || item.symbol.lowercased().contains(query.lowercased())
    }
    didUpdate?()
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
