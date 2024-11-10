//
//  CryptoCoinFilterTest.swift
//  CryptoCoin
//
//  Created by Saiprasad on 11/11/24.
//

import XCTest
@testable import CryptoCoin

@MainActor
class CryptoCoinFilterTests: XCTestCase {
  
  var viewModel: CryptoListViewModel!
  var mockSession: MockURLSession!
  var mockDatabaseManager: MockDatabaseManagerProtocol!
  
  override func setUp() {
    super.setUp()
    mockSession = MockURLSession()
    mockDatabaseManager = MockDatabaseManagerProtocol()
    viewModel = CryptoListViewModel(networkProtocol: mockSession, database: mockDatabaseManager)
  }
  
  // Test applyFilters with "Active Coin" filter
  func testActiveCoinFilter() {
    let expectation = XCTestExpectation(description: "Filtered data should contain only active coins")
    
    let filterCriteria = FilterCriteria(isActive: true, type: "coin")
    viewModel.updateFilters(criteria: filterCriteria, isSelected: true)
    

    let expectedFilteredData = self.viewModel.coins.filter { $0.isActive == true && $0.type == "coin" }
    XCTAssertEqual(viewModel.filteredCoins.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  // Test applyFilters with "Inactive Token" filter
  func testInactiveCoinFilter() {
    
    let filterCriteria = FilterCriteria(isActive: false, type: "coin")
    viewModel.updateFilters(criteria: filterCriteria, isSelected: true)
    let expectation = XCTestExpectation(description: "Filtered data should contain only Inactive coin")
    let expectedFilteredData = self.viewModel.coins.filter { $0.isActive == false && $0.type == "coin" }
        XCTAssertEqual(viewModel.filteredCoins.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
    
    wait(for: [expectation], timeout: 1.0)
    
  }
  
  // Test applyFilters with "New Coins" filter
  func testNewCoinFilter() {
    let filterCriteria = FilterCriteria(type: "coin", isNew: true)
    viewModel.updateFilters(criteria: filterCriteria, isSelected: true)
    
    let expectation = XCTestExpectation(description: "Filtered data should contain only new coins")
    let expectedFilteredData = self.viewModel.coins.filter { $0.isNew == true && $0.type == "coin" }
        XCTAssertEqual(viewModel.filteredCoins.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
    
    wait(for: [expectation], timeout: 1.0)
    
  }
  
  // Test applyFilters with "All Tokens" filter
  func testAllTokensFilter() {
    let filterCriteria = FilterCriteria(type: "token")
    viewModel.updateFilters(criteria: filterCriteria, isSelected: true)
    
    let expectation = XCTestExpectation(description: "Filtered data should contain only tokens")

    let expectedFilteredData = self.viewModel.coins.filter { $0.type == "token" }
    XCTAssertEqual(viewModel.filteredCoins.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
    
    wait(for: [expectation], timeout: 1.0)
    
  }
  
  func testAllCoinsFilter() {
    let filterCriteria = FilterCriteria(type: "coin")
    viewModel.updateFilters(criteria: filterCriteria, isSelected: true)
    
    let expectation = XCTestExpectation(description: "Filtered data should contain only coins")

    let expectedFilteredData = self.viewModel.coins.filter { $0.type == "coin" }
    XCTAssertEqual(viewModel.filteredCoins.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
    
    wait(for: [expectation], timeout: 1.0)
    
  }
  
  func testMultipleSelectionFilter() {
    let filterCriteria1 = FilterCriteria(isActive: true, type: "coin")
    viewModel.updateFilters(criteria: filterCriteria1, isSelected: true)
    let filterCriteria2 = FilterCriteria(isActive: false, type: "coins")
    viewModel.updateFilters(criteria: filterCriteria2, isSelected: true)
    
    let expectation = XCTestExpectation(description: "Filtered data should contain coins and tokens")
    let expectedFilteredData = self.viewModel.coins.filter { $0.type == "coin" }
    XCTAssertEqual(viewModel.filteredCoins.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
    
    wait(for: [expectation], timeout: 1.0)
    
  }
  
  override func tearDown() {
    // Reset any necessary state
    viewModel = nil
    super.tearDown()
  }
}
