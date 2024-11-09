//
//  CoinTableViewCell.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

import UIKit

class CoinTableViewCell: UITableViewCell {
  
  fileprivate let nameLabel = UILabel()
  fileprivate let symbolLabel = UILabel()
  fileprivate var imageViewContainer: UIImageView!
  fileprivate var newDataBadge: UIImageView!
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
    self.isUserInteractionEnabled = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    symbolLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    symbolLabel.textColor = .gray
    // Setup image view container (for right side image)
    
    imageViewContainer = UIImageView()
    imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
    imageViewContainer.contentMode = .scaleAspectFill
    imageViewContainer.clipsToBounds = true
    contentView.addSubview(imageViewContainer)
    
    // Setup new data badge (small circle on top of image)
    newDataBadge = UIImageView()
    newDataBadge.translatesAutoresizingMaskIntoConstraints = false
    newDataBadge.image = UIImage(named: Constants.ImageConstants.newBadge)
    newDataBadge.isHidden = true
    contentView.addSubview(newDataBadge)
    setupConstraints()
  }
  
  // Method to add constraints
  private func setupConstraints() {
    // Label constraints (left side)
    let stackView = UIStackView(arrangedSubviews: [nameLabel, symbolLabel])
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
    ])
    
    // Image view container constraints (right side)
    NSLayoutConstraint.activate([
      imageViewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      imageViewContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      imageViewContainer.widthAnchor.constraint(equalToConstant: 40),
      imageViewContainer.heightAnchor.constraint(equalToConstant: 40)
    ])
    
    // New data badge constraints (top-right of image)
    NSLayoutConstraint.activate([
      newDataBadge.topAnchor.constraint(equalTo: imageViewContainer.topAnchor, constant: -5),
      newDataBadge.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor, constant: 5),
      newDataBadge.widthAnchor.constraint(equalToConstant: 20),
      newDataBadge.heightAnchor.constraint(equalToConstant: 20)
    ])
  }
  
  func configure(with coin: CryptoCoin) {
    nameLabel.text = coin.name
    symbolLabel.text = coin.symbol
    if (coin.isActive && coin.type == CryptoTypes.coin.rawValue) {
      imageViewContainer.image =  UIImage(named: Constants.ImageConstants.coinActive)
    } else if(coin.isActive && coin.type == CryptoTypes.token.rawValue) {
      imageViewContainer.image =  UIImage(named: Constants.ImageConstants.tokenActive)
    } else {
      imageViewContainer.image =  UIImage(named: Constants.ImageConstants.inactive)
    }
    newDataBadge.isHidden = !coin.isNew
    nameLabel.textColor = coin.isActive ? .black : .gray
  }
}
