//
//  CryptoServiceProtocol.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

import Foundation

protocol CryptoServiceProtocol {
  func fetchCryptoCoins<T: Decodable>(completion: @Sendable @escaping (Result<T, any Error>) -> Void)
}

class MockCryptoService: CryptoServiceProtocol {
  var mockCoins: [CryptoCoin] = []
  var shouldFail = false
  
  func fetchCryptoCoins<T: Decodable>(completion: @Sendable @escaping (Result<T, any Error>) -> Void) {
    if shouldFail {
      completion(.failure(NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch coins"])))
    } else {
      completion(.success(mockCoins as! T))
    }
  }
}
