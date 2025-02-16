//
//  ItemsViewController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import UIKit

final class ItemsViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.identifier)
        cv.register(FullItemCell.self, forCellWithReuseIdentifier: FullItemCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private let emptyStateView = EmptyStateView()
    
    private lazy var recentSearchesVC: RecentSearchesViewController = {
        let vc = RecentSearchesViewController()
        vc.onSelectQuery = { [weak self] query in
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
        return vc
    }()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: recentSearchesVC)
        sc.searchBar.placeholder = "Поиск продуктов"
        sc.searchBar.delegate = self
        return sc
    }()
    
    private let viewModel: ItemsViewModel
    
    init(viewModel: ItemsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "Продукты"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupEmptyStateView()
        setupSearchController()
        bindViewModel()
        viewModel.handle(.onAppear)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "cart.fill"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cartButtonTapped))
    }
    
    private func setupEmptyStateView() {
        emptyStateView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        emptyStateView.isHidden = true
    }
    
    @objc private func retryButtonTapped() {
        navigationItem.searchController?.searchBar.text = ""
        viewModel.clearFilter()
        viewModel.handle(.onAppear)
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
                    self?.viewModel.items = viewData.products
                    if viewData.products.isEmpty {
                        self?.collectionView.isHidden = true
                        self?.emptyStateView.isHidden = false
                    } else {
                        self?.collectionView.isHidden = false
                        self?.emptyStateView.isHidden = true
                    }
                    self?.collectionView.reloadData()
                case .error(let message):
                    let alert = UIAlertController(title: "Ошибка",
                                                  message: message,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок", style: .default))
                    self?.present(alert, animated: true)
                default:
                    break
                }
            }
        }
    }
    
    private func setupSearchController() {
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
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
        navigationItem.searchController?.isActive = false
        searchBar.resignFirstResponder()
    }
}

extension ItemsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let recentVC = searchController.searchResultsController as? RecentSearchesViewController {
            recentVC.tableView.reloadData()
        }
    }
}

extension ItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let productVM = viewModel.items[indexPath.item]
        return viewModel.configuredCell(for: collectionView,
                                        at: indexPath,
                                        categoryId: productVM.originalDTO.category.id)
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let insets = layout?.sectionInset ?? .zero
        let spacing = layout?.minimumInteritemSpacing ?? 0
        return viewModel.cellSize(for: collectionView.frame.width,
                                  at: indexPath.item,
                                  insets: insets,
                                  interItemSpacing: spacing)
    }
}

extension ItemsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.items.count - 1 {
            viewModel.handle(.willDisplayLastItem)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productDTO = viewModel.items[indexPath.item].originalDTO
        viewModel.handle(.onSelectItem(productDTO))
    }
}
