//
//  LoaderView.swift
//  CryptoCoin
//
//  Created by Saiprasad on 09/11/24.
//

import UIKit

class LoaderView: UIView {
  
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  
  init() {
    super.init(frame: .zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    // Configure the loader view
    self.backgroundColor = UIColor(white: 0, alpha: 0.6) // Semi-transparent background
    self.layer.cornerRadius = 10
    
    // Set up the activity indicator
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(activityIndicator)
    
    // Center the activity indicator
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ])
    
    activityIndicator.hidesWhenStopped = true
  }
  
  // Start the loading animation
  func startLoading() {
    activityIndicator.startAnimating()
  }
  
  // Stop the loading animation
  func stopLoading() {
    activityIndicator.stopAnimating()
  }
}
