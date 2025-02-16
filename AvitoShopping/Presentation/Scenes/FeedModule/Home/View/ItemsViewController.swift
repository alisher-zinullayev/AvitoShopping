//
//  ItemsViewController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import UIKit

final class ItemsViewController: UIViewController {
    private var collectionView: UICollectionView!
    private let viewModel: ItemsViewModel
    private var items: [ProductItemViewModel] = [] // move to view model
    
    private var recentSearchesVC: RecentSearchesViewController!
    private var searchController: UISearchController!
    
    init(viewModel: ItemsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "Products"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupSearchController()
        bindViewModel()
        viewModel.handle(.onAppear)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "cart.fill"), style: .plain, target: self, action: #selector(cartButtonTapped))
    }
    
    @objc private func cartButtonTapped() {
        let cartVC = ShoppingCartViewController()
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loaded(let viewData):
                    self?.items = viewData.products
                    self?.collectionView.reloadData()
                case .error(let message):
                    let alert = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                default:
                    break
                }
            }
        }
    }
    
    private func setupSearchController() {
        recentSearchesVC = RecentSearchesViewController()
        recentSearchesVC.onSelectQuery = { [weak self] query in
            RecentSearchManager.shared.addSearchQuery(query)
            let filter = ProductFilter(title: query,
                                       priceMin: nil,
                                       priceMax: nil,
                                       categoryId: nil,
                                       offset: 0,
                                       limit: 10)
            self?.viewModel.applyFilter(filter)
            self?.searchController.isActive = false
        }
        
        searchController = UISearchController(searchResultsController: recentSearchesVC)
        searchController.searchBar.placeholder = "Search products"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(filterButtonTapped))
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.modalPresentationStyle = .formSheet
        filterVC.onApplyFilter = { [weak self] filter in
            self?.viewModel.applyFilter(filter)
        }
        present(filterVC, animated: true)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ItemsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let recentVC = searchController.searchResultsController as? RecentSearchesViewController {
            recentVC.tableView.reloadData()
        }
    }
}

extension ItemsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.clearFilter()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        RecentSearchManager.shared.addSearchQuery(query)
        let filter = ProductFilter(title: query,
                                   priceMin: nil,
                                   priceMax: nil,
                                   categoryId: nil,
                                   offset: 0,
                                   limit: 10)
        viewModel.applyFilter(filter)
        searchController.isActive = false
        searchBar.resignFirstResponder()
    }
}



extension ItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
        
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.identifier,
                                                            for: indexPath) as? ItemCell else {
            return UICollectionViewCell()
        }
        let productViewModel = items[indexPath.item]
        cell.configure(with: productViewModel)
        cell.onFavoriteTapped = { [weak self] in
            print("Favorite tapped for product id: \(productViewModel.imageUrl)")
        }
        cell.onAddToCartTapped = { [weak self] in
            self?.viewModel.addToCartButtonTapped(for: productViewModel.originalDTO)
            print("Add to cart tapped for product id: \(productViewModel.id)")
        }
        return cell
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let insets = layout?.sectionInset ?? .zero
        let spacing = layout?.minimumInteritemSpacing ?? 0
        let totalPadding = insets.left + insets.right + spacing
        let availableWidth = collectionView.frame.width - totalPadding
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: cellWidth * 1.3)
    }
}

extension ItemsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.item == items.count - 1 {
            viewModel.handle(.willDisplayLastItem)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productDTO = items[indexPath.item].originalDTO
        viewModel.handle(.onSelectItem(productDTO))
    }
}
