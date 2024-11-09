//
//  FilterBottomSheetView.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//


import UIKit

class FilterBottomViewController: UIViewController {
  private let options = [CryptoTypes.activeCoin.rawValue, CryptoTypes.inactiveCoin.rawValue, CryptoTypes.onlyToken.rawValue, CryptoTypes.onlyCoin.rawValue, CryptoTypes.newCoin.rawValue]
  private var selectedOptions: Set<String> = []
  var filterSelectionHandler: (([String]) -> Void)?
  
  var scrollView: UIScrollView!
  var buttons: [UIButton] = []
  
  let buttonSpacing: CGFloat = 10
  let padding: CGFloat = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    setupScrollView()
    createButtons(with: options)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    if !scrollView.frame.contains(touches.first!.location(in: view)) {
      dismiss(animated: true, completion: nil)
    }
  }
  
  private func setupScrollView() {
    scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .white
    scrollView.layer.cornerRadius = 12
    scrollView.clipsToBounds = true
    view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func createButtons(with texts: [String]) {
    var currentRowStartX: CGFloat = 0
    var currentRowY: CGFloat = 10
    
    for text in texts {
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle(text, for: .normal)
      button.layer.borderWidth = 1
      button.layer.borderColor = UIColor.black.cgColor
      button.layer.cornerRadius = 8
      button.clipsToBounds = true
      button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
      
      scrollView.addSubview(button)
      buttons.append(button)
      
      let buttonWidth = button.intrinsicContentSize.width + 40
      
      if currentRowStartX + buttonWidth > view.frame.width - (2 * padding) {
        currentRowStartX = 0
        currentRowY += 44 + buttonSpacing
      }
      
      NSLayoutConstraint.activate([
        button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: currentRowStartX + 10),
        button.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: currentRowY),
        button.widthAnchor.constraint(equalToConstant: buttonWidth),
        button.heightAnchor.constraint(equalToConstant: 44)
      ])
      
      currentRowStartX += buttonWidth + buttonSpacing
    }
    
    scrollView.contentSize = CGSize(width: view.frame.width - (2 * padding), height: currentRowY + 54)
    
    let scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: min(scrollView.contentSize.height + 20, view.frame.height - 100))
    scrollViewHeightConstraint.isActive = true
  }
  
  @objc private func buttonTapped(_ sender: UIButton) {
    let buttonText = sender.title(for: .normal) ?? ""
    
    if selectedOptions.contains(buttonText) {
      sender.setImage(nil, for: .normal)
      selectedOptions.remove(buttonText)
    } else {
      sender.setImage(UIImage(systemName: Constants.ImageConstants.circleImage), for: .normal)
      selectedOptions.insert(buttonText)
    }
    
    // Call the handler with the updated selected options
    filterSelectionHandler?(Array(selectedOptions))
  }
}
