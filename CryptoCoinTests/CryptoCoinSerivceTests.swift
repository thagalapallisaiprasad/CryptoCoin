//
//  CryptoCoinTests.swift
//  CryptoCoinTests
//
//  Created by Saiprasad on 08/11/24.
//

import XCTest
import CoreData
@testable import CryptoCoin

// Mock URLSession for testing purposes
class MockURLSession: NetworkProtocol {
  var mockError: Error?
  var mockResponse: URLResponse?
  var mockData: Data? // Allow setting mock data for tests
  
  func sessionDataTask<T: Decodable>(with url: URL, completionHandler: @escaping (Result<T, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
      if let error = self.mockError {
        completionHandler(.failure(error))
        return
      }
      
      if let mockData = self.mockData {
        do {
          let decoder = JSONDecoder()
          let decodedData = try decoder.decode(T.self, from: mockData)
          completionHandler(.success(decodedData))
        } catch {
          completionHandler(.failure(error))
        }
      }
    }
  }
}

class MockDatabaseManagerProtocol: DatabaseManagerProtocol {
  var shouldReturnEmpty = false
  var savedCoins = [CryptoCoin]()
  
  func saveContext(context: NSManagedObjectContext) throws {
    savedCoins = [
      CryptoCoin(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: false),
      CryptoCoin(name: "Ethereum", symbol: "ETH", type: "token", isActive: true, isNew: false)
    ]
  }
  
  func saveCryptoCoin(_ coin: CryptoCoin) throws {
    savedCoins.append(coin)
  }
  
  func fetchCryptoCoins() throws -> [CryptoCoin] {
    return shouldReturnEmpty ? [] : savedCoins
  }
}

@MainActor
// Test Class
class CryptoServiceTests: XCTestCase {
  var viewModel: CryptoListViewModel!
  var mockSession: MockURLSession!
  var mockDatabaseManager: MockDatabaseManagerProtocol!
  
  override func setUp() {
    super.setUp()
    mockSession = MockURLSession()
    mockDatabaseManager = MockDatabaseManagerProtocol()
    viewModel = CryptoListViewModel(networkProtocol: mockSession, database: mockDatabaseManager)
  }
  
  override func tearDown() {
    mockSession = nil
    super.tearDown()
  }
  
  // Test for successful response
  func testFetchCryptoCoinsSuccess() {
    // Arrange: Prepare mock data
    let expectation = self.expectation(description: "Fetch crypto coins")
    
    let mockData = Data("""
    [{
        "name": "Bitcoin",
        "symbol": "BTC",
        "is_new": false,
        "is_active": true,
        "type": "coin"
    },
    {
        "name": "Ethereum",
        "symbol": "ETH",
        "is_new": false,
        "is_active": true,
        "type": "token"
    }]
    """.utf8)
    
    mockSession.mockData = mockData
    
    // Act: Call the method
    viewModel.fetchCoins()
    
    // Assert: Wait for the viewModel to update
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      XCTAssertEqual(self.viewModel.coins.count, 2, "The number of coins should be 2")
      XCTAssertEqual(self.viewModel.coins[0].name, "Bitcoin", "First coin should be Bitcoin")
      XCTAssertEqual(self.viewModel.coins[1].name, "Ethereum", "Second coin should be Ethereum")
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 6.0)
  }
  
  // Test for failure response
  func testFetchCryptoCoinsFailure() {
    // Arrange: Prepare mock error
    let mockError = NSError(domain: "NetworkError", code: 500, userInfo: nil)
    mockSession.mockError = mockError
    let expectation = self.expectation(description: "Fetch crypto coins failure")
    
    // Act: Call the method
    viewModel.fetchCoins()
    
    // Assert: Wait for the completion and assert the state of the view model
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      XCTAssertTrue(self.viewModel.coins.isEmpty, "The coins list should be empty on failure")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 6.0)
  }
  
  // Test for decoding error (if mock data is corrupted)
  func testFetchCryptoCoinsDecodingFailure() {
    // Arrange: Prepare mock invalid data (this will fail to decode into an array of CryptoCoin)
    let invalidData = Data("invalid data".utf8)
    mockSession.mockData = invalidData
    mockSession.mockError = nil
    
    let expectation = self.expectation(description: "Fetch crypto coins decoding failure")
    
    // Act: Call the method
    viewModel.fetchCoins()
    
    // Assert: Wait for the completion and assert the state of the view model
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      XCTAssertTrue(self.viewModel.coins.isEmpty, "The coins list should be empty on decoding failure")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 6.0)
  }
}
