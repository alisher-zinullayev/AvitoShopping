//
//  ItemsViewController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import UIKit

class ItemsViewController: UIViewController {
    private var collectionView: UICollectionView!
    private let viewModel: ItemsViewModel
    private var items: [ProductItemViewModel] = []
    
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
    
//    private func setupSearchController() {
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchBar.placeholder = "Search products"
//        // Настраиваем кнопку фильтра справа в поисковой строке через accessory view, если нужно,
//        // либо используем navigationItem.rightBarButtonItem:
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
//                                                            style: .plain,
//                                                            target: self,
//                                                            action: #selector(filterButtonTapped))
//    }
    
    private func setupSearchController() {
            // Create a search controller and assign it to the navigation item
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.placeholder = "Search products"
            searchController.searchBar.delegate = self  // Set self as delegate
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
            
            // Optionally, keep the filter button on the right
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(filterButtonTapped))
        }
    
    @objc private func filterButtonTapped() {
        // Представляем экран фильтра (как full screen или bottom sheet)
        let filterVC = FilterViewController()
        // Можно установить modalPresentationStyle = .pageSheet или .formSheet или использовать UISheetPresentationController (iOS 15+)
        filterVC.modalPresentationStyle = .pageSheet
        filterVC.onApplyFilter = { [weak self] filter in
            // Передаем выбранные параметры в viewModel
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
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.reuseIdentifier)
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

extension ItemsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Clear search text and load unfiltered products.
        searchBar.text = ""
        viewModel.clearFilter()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Update the current filter's title and reload data.
        var filter = ProductFilter(title: searchText,
                                   priceMin: nil,
                                   priceMax: nil,
                                   categoryId: nil,
                                   offset: 0,
                                   limit: 10)
        // If there's an existing filter (applied via FilterViewController), merge it here:
        if let current = viewModel.currentFilter {
            filter = ProductFilter(title: searchText,
                                   priceMin: current.priceMin,
                                   priceMax: current.priceMax,
                                   categoryId: current.categoryId,
                                   offset: 0,
                                   limit: 10)
        }
        viewModel.applyFilter(filter)
    }
}



extension ItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
        
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.reuseIdentifier,
                                                            for: indexPath) as? ItemCell else {
            return UICollectionViewCell()
        }
        let productViewModel = items[indexPath.item]
        cell.configure(with: productViewModel)
        cell.onFavoriteTapped = { [weak self] in
            // In a real scenario, convert ProductItemViewModel back to Product model if needed.
            // For demonstration, assume you have a method or mapping.
            // self?.viewModel.favoriteButtonTapped(for: product)
            print("Favorite tapped for product id: \(productViewModel.imageUrl)")
        }
        cell.onAddToCartTapped = { [weak self] in
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
}

class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .systemBlue : .lightGray
            titleLabel.textColor = isSelected ? .white : .black
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .lightGray
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with category: Category) {
        titleLabel.text = category.name
    }
}
