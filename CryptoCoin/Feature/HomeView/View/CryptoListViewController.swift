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
    setupLoader()
    showLoader()
    viewModel.fetchCoins()
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
    tableView.register(CoinTableViewCell.self, forCellReuseIdentifier: "CoinCell")
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
    searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
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
  }
  
  private func bindViewModel() {
    viewModel.didUpdate = { [weak self] in
      DispatchQueue.main.async {
        self?.hideLoader()
        self?.tableView.reloadData()
      }
    }
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
    // Clear any previously applied filters
    viewModel.clearFilters()
    
    // Apply each filter from the selected filters list
    for filter in filters {
      switch filter {
        case "Active Coins":
          viewModel.toggleActiveFilter()
        case "Inactive Coins":
          viewModel.toggleInactiveFilter()
        case "Only Tokens":
          viewModel.toggleTokensFilter()
        case "Only Coins":
          viewModel.toggleCoinsFilter()
        case "New Coins":
          viewModel.toggleNewCoinsFilter()
        default:
          break
      }
    }
    
    // Refresh the filtered coins list
    viewModel.applyFilters()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.filteredCoins.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CoinCell", for: indexPath) as! CoinTableViewCell
    let coin = viewModel.filteredCoins[indexPath.row]
    cell.configure(with: coin)
    return cell
  }
}
