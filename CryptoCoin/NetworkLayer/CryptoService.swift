//
//  CryptoService.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//
import Foundation

class CryptoService: CryptoServiceProtocol {
  private let url: URL
  
  init(url: URL = URL(string: Constants.API.baseURL)!) {
    self.url = url
  }
  
  func fetchCryptoCoins<T: Decodable>(completion: @Sendable @escaping (Result<T, any Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error as any Error))
        return
      }
      
      guard let data = data else {
        completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil) as any Error))
        return
      }
      
      do {
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        completion(.success(decodedData))
      } catch {
        completion(.failure(error as any Error))
      }
    }
    task.resume()
  }
}
