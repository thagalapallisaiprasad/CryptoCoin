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
  
  func fetchCryptoCoins<T: Decodable>(completion: @Sendable @escaping (Result<T, any Error>) -> Void) {
    completion(.success(mockCoins as! T))
  }
}
