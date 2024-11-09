//
//  CryptoListViewController.swift
//  CryptoCoin
//
//  Created by Saiprasad on 08/11/24.
//

import UIKit

class CryptoListViewController: UIViewController, UITableViewDataSource {
  
  private let viewModel = CryptoListViewModel()
  private var loaderView: LoaderView!
  private let tableView = UITableView()
  private let searchButton = UIButton()
  private var filterBottomSheetViewController: FilterBottomViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bindViewModel()
    viewModel.fetchCoins()
  }
  
  private func setupUI() {
    view.backgroundColor = .white
    let headerView = UIView()
    headerView.backgroundColor = .blue
    headerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(headerView)
    
    let safeArea = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      headerView.heightAnchor.constraint(equalToConstant: 60)
    ])
    
    setupSearchButton(headerView)
    setupTableView(headerView, safeArea)
    setupLoader()
    showLoader()
  }
  
  private func bindViewModel() {
    viewModel.didUpdate = { [weak self] in
      DispatchQueue.main.async {
        self?.hideLoader()
        self?.tableView.reloadData()
      }
    }
  }
  
  private func setupLoader() {
    // Initialize the loader view
    loaderView = LoaderView()
    loaderView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(loaderView)
    
    // Add constraints to make it fill the screen
    NSLayoutConstraint.activate([
      loaderView.topAnchor.constraint(equalTo: view.topAnchor),
      loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  // Call this function when you want to show the loader
  func showLoader() {
    loaderView.isHidden = false
    loaderView.startLoading()
  }
  
  // Call this function to hide the loader
  func hideLoader() {
    loaderView.stopLoading()
    loaderView.isHidden = true
  }
  
  fileprivate func setupTableView(_ headerView: UIView, _ safeArea: UILayoutGuide) {
    tableView.dataSource = self
    tableView.register(CoinTableViewCell.self, forCellReuseIdentifier: Constants.StringConstants.cellIdentifier)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
    ])
  }
  
  fileprivate func setupSearchButton(_ headerView: UIView) {
    searchButton.setImage(UIImage(systemName: Constants.ImageConstants.searchImage), for: .normal)
    searchButton.tintColor = .white
    searchButton.addTarget(self, action: #selector(showFilterBottomSheet), for: .touchUpInside)
    searchButton.translatesAutoresizingMaskIntoConstraints = false
    headerView.addSubview(searchButton)
    
    NSLayoutConstraint.activate([
      searchButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
      searchButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
      searchButton.widthAnchor.constraint(equalToConstant: 30),
      searchButton.heightAnchor.constraint(equalToConstant: 30)
    ])
  }
  
  @objc private func showFilterBottomSheet() {
    if filterBottomSheetViewController == nil {
      filterBottomSheetViewController = FilterBottomViewController()
      
      filterBottomSheetViewController?.filterSelectionHandler = { [weak self] selectedFilters in
        self?.applyMultipleFilters(selectedFilters)
      }
      
      filterBottomSheetViewController?.modalPresentationStyle = .overCurrentContext
      filterBottomSheetViewController?.modalTransitionStyle = .crossDissolve
    }
    
    present(filterBottomSheetViewController ?? UIViewController(), animated: true)
  }
  
  private func applyMultipleFilters(_ filters: [String]) {
    var criteria = FilterCriteria()
    
    for filter in filters {
      switch filter {
        case CryptoTypes.activeCoin.rawValue:
          criteria.isActive = true
          criteria.type = CryptoTypes.coin.rawValue
        case CryptoTypes.inactiveCoin.rawValue:
          criteria.isActive = false
          criteria.type = CryptoTypes.coin.rawValue
        case CryptoTypes.onlyToken.rawValue:
          criteria.type = CryptoTypes.token.rawValue
        case CryptoTypes.onlyCoin.rawValue:
          criteria.type = CryptoTypes.coin.rawValue
        case CryptoTypes.newCoin.rawValue:
          criteria.isNew = true
          criteria.type = CryptoTypes.coin.rawValue
        default:
          break
      }
    }
    
    viewModel.updateFilter(criteria)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.filteredCoins.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.StringConstants.cellIdentifier, for: indexPath) as! CoinTableViewCell
    let coin = viewModel.filteredCoins[indexPath.row]
    cell.configure(with: coin)
    return cell
  }
}
