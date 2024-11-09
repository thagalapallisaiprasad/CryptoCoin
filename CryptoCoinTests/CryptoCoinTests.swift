//
//  CryptoCoinTests.swift
//  CryptoCoinTests
//
//  Created by Saiprasad on 08/11/24.
//

import XCTest
@testable import CryptoCoin

@MainActor
final class CryptoListViewModelTests: XCTestCase {
  var viewModel: CryptoListViewModel!
  var mockService: MockCryptoService!
  
  override func setUp() {
    super.setUp()
    mockService = MockCryptoService()
    viewModel = CryptoListViewModel(service: mockService)
  }
  
  override func tearDown() {
    viewModel = nil
    mockService = nil
    super.tearDown()
  }
  
  func testClearFiltersResetsAllFiltersAndShowsAllCoins() {
    // Arrange
    let initialCoins = [
      CryptoCoin(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: false),
      CryptoCoin(name: "Ethereum", symbol: "ETH", type: "coin", isActive: true, isNew: true),
      CryptoCoin(name: "USDT", symbol: "USDT", type: "token", isActive: false, isNew: false)
    ]
    mockService.mockCoins = initialCoins
    
    // Act
    viewModel.fetchCoins()
    
    // Apply filters to simulate user activity
    viewModel.filterCriteria.isActive = true
    viewModel.filterCriteria.type = "coin"
    viewModel.applyFilters()
    
    // Verify that filters are applied
    XCTAssertEqual(viewModel.filteredCoins.count, 2, "Expected filtered coins count before clearing filters.")
    
    // Call clearFilters
    viewModel.clearFilters()
    
    // Assert that all filters are reset
    XCTAssertNil(viewModel.filterCriteria.isActive, "Expected isActive filter to be nil after clearing filters.")
    XCTAssertNil(viewModel.filterCriteria.type, "Expected type filter to be nil after clearing filters.")
    XCTAssertNil(viewModel.filterCriteria.isNew, "Expected isNew filter to be nil after clearing filters.")
    
    // Assert that all coins are displayed after clearing filters
    XCTAssertEqual(viewModel.filteredCoins.count, initialCoins.count, "Expected all coins to be displayed after clearing filters.")
  }
}
