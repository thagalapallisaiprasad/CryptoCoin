//
//  UIView+Extensions.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

import UIKit

extension UIView {
  func addShadow(radius: CGFloat = 4, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0, height: 2)) {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offset
    layer.shadowRadius = radius
  }
  
  func roundCorners(radius: CGFloat) {
    layer.cornerRadius = radius
    layer.masksToBounds = true
  }
}
