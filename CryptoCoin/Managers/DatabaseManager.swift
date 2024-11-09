//
//  DatabaseManager.swift
//  CryptoCoin
//
//  Created by Saiprasad on 09/11/24.
//

import CoreData
import Foundation
import UIKit

protocol DatabaseManagerProtocol {
  func saveContext(context: NSManagedObjectContext) throws
  func saveCryptoCoin(_ coin: CryptoCoin) throws
  func fetchCryptoCoins() throws -> [CryptoCoin]
}

class DatabaseManager: @preconcurrency DatabaseManagerProtocol {
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CryptoCoin")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  func saveContext(context: NSManagedObjectContext) throws {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        throw error
      }
    }
  }
  
  @MainActor func saveCryptoCoin(_ coin: CryptoCoin) throws {
    let managedContext = persistentContainer.viewContext
    let coinEntity = CoinEntity(context: managedContext)
    coinEntity.name = coin.name
    coinEntity.symbol = coin.symbol
    coinEntity.type = coin.type
    coinEntity.isActive = coin.isActive
    coinEntity.isNew = coin.isNew
    
    try saveContext(context: managedContext)
  }
  
  @MainActor func fetchCryptoCoins() throws -> [CryptoCoin] {
    let managedContext = persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<CoinEntity> = CoinEntity.fetchRequest()
    
    let coinEntities = try managedContext.fetch(fetchRequest)
    return coinEntities.map { coinEntity in
      CryptoCoin(name: coinEntity.name ?? "",
                 symbol: coinEntity.symbol ?? "",
                 type: coinEntity.type ?? "",
                 isActive: coinEntity.isActive,
                 isNew: coinEntity.isNew)
    }
  }
  
}
