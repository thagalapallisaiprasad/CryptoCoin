//
//  CryptoServiceProtocol.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

import Foundation

protocol NetworkProtocol {
  func sessionDataTask<T: Decodable>(with url: URL, completionHandler: @Sendable @escaping (Result<T, Error>) -> Void)
}

extension URLSession: NetworkProtocol {
  func sessionDataTask<T: Decodable>(with url: URL, completionHandler: @Sendable @escaping (Result<T, Error>) -> Void) {
    let task = self.dataTask(with: url) { data, response, error in
      // Handle network error
      if let error = error {
        completionHandler(.failure(error))
        return
      }
      
      // Check if data exists
      guard let data = data else {
        completionHandler(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
        return
      }
      
      // Decode the data
      do {
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        completionHandler(.success(decodedData))
      } catch {
        completionHandler(.failure(error))
      }
    }
    task.resume()
  }
}
