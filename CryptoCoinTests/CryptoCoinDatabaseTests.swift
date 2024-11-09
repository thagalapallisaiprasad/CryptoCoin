
//
//  Untitled.swift
//  CryptoCoin
//
//  Created by Saiprasad on 09/11/24.
//

import XCTest
import CoreData
@testable import CryptoCoin

class DatabaseManagerTests: XCTestCase {
  
  var databaseManager: MockDatabaseManager!
  var mockPersistentContainer: NSPersistentContainer!
  
  override func setUp() {
    super.setUp()
    
    // Initialize a mock Core Data stack
    mockPersistentContainer = NSPersistentContainer(name: "CryptoCoin")
    mockPersistentContainer.persistentStoreDescriptions = [NSPersistentStoreDescription()]
    mockPersistentContainer.loadPersistentStores { description, error in
      if let error = error {
        fatalError("Failed to load persistent stores: \(error)")
      }
    }
    
    databaseManager = MockDatabaseManager()
  }
  
  override func tearDown() {
    databaseManager = nil
    mockPersistentContainer = nil
    super.tearDown()
  }
  
  func testFetchProductById() {
    // Given: Create mock products (CryptoCoins)
    let product1 = CryptoCoin(name: "Ripple", symbol: "XRP", type: "coin", isActive: true, isNew: true)
    let product2 = CryptoCoin(name: "ChainLink", symbol: "LINK", type: "token", isActive: true, isNew: true)
    let product3 = CryptoCoin(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: true)
    
    // Given: Set up the Core Data context for inserting objects
    let context = mockPersistentContainer.newBackgroundContext()
    
    // Set up expectation for context save notification
    expectation(forNotification: .NSManagedObjectContextDidSave, object: context) { _ in
      return true
    }
    
    // Insert mock data into Core Data (Create CoinEntity objects and assign CryptoCoin values)
    let coinEntity1 = CoinEntity(context: context)
    coinEntity1.name = product1.name
    coinEntity1.symbol = product1.symbol
    coinEntity1.type = product1.type
    coinEntity1.isActive = product1.isActive
    coinEntity1.isNew = product1.isNew
    
    let coinEntity2 = CoinEntity(context: context)
    coinEntity2.name = product2.name
    coinEntity2.symbol = product2.symbol
    coinEntity2.type = product2.type
    coinEntity2.isActive = product2.isActive
    coinEntity2.isNew = product2.isNew
    
    let coinEntity3 = CoinEntity(context: context)
    coinEntity3.name = product3.name
    coinEntity3.symbol = product3.symbol
    coinEntity3.type = product3.type
    coinEntity3.isActive = product3.isActive
    coinEntity3.isNew = product3.isNew
    
    // Save the context to persist the objects
    try! context.save()
    
    // Wait for the save operation to complete
    waitForExpectations(timeout: 2.0) { error in
      XCTAssertNil(error, "Save did not occur")
    }
    
    // Act: Fetch the product by ID (or name, symbol, etc.)
    let fetchRequest: NSFetchRequest<CoinEntity> = CoinEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "symbol == %@", "XRP") // Fetch by symbol for example
    
    do {
      let fetchedCoins = try context.fetch(fetchRequest)
      XCTAssertEqual(fetchedCoins.count, 1, "Expected to find exactly one CoinEntity with the symbol 'XRP'")
      XCTAssertEqual(fetchedCoins.first?.name, "Ripple", "Expected the fetched coin to be 'Ripple'")
    } catch {
      XCTFail("Failed to fetch products by ID: \(error.localizedDescription)")
    }
  }
}

class MockDatabaseManager {
  lazy var mockpersistentContainer: NSPersistentContainer = {
    let description = NSPersistentStoreDescription()
    description.url = URL(fileURLWithPath: "/dev/null")
    let container = NSPersistentContainer(name: "CryptoCoin")
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
}
