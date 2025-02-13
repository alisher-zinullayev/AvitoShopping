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
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search products"
        // Настраиваем кнопку фильтра справа в поисковой строке через accessory view, если нужно,
        // либо используем navigationItem.rightBarButtonItem:
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

//class FilterViewController: UIViewController {
//
//    // Closure to pass the selected filter back
//    var onApplyFilter: ((ProductFilter) -> Void)?
//
//    // Collection view for categories
//    private var collectionView: UICollectionView!
//    // Two text fields for price range input
//    private var priceMinTextField: UITextField!
//    private var priceMaxTextField: UITextField!
//    // Apply Filter button
//    private var applyButton: UIButton!
//    
//    // Sample categories – you could replace this with real data
//    private let categories: [Category] = [
//        Category(id: 1, name: "Clothes", image: ""),
//        Category(id: 2, name: "Electronics", image: ""),
//        Category(id: 3, name: "Home", image: ""),
//        Category(id: 4, name: "Toys", image: "")
//    ]
//    
//    // Currently selected category id (if any)
//    private var selectedCategoryId: Int?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        setupUI()
//    }
//    
//    private func setupUI() {
//        // --- Setup category collection view ---
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 10
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .white
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
//        view.addSubview(collectionView)
//        
//        // --- Setup price text fields ---
//        priceMinTextField = UITextField()
//        priceMinTextField.translatesAutoresizingMaskIntoConstraints = false
//        priceMinTextField.placeholder = "Min Price"
//        priceMinTextField.borderStyle = .roundedRect
//        priceMinTextField.keyboardType = .numberPad
//        view.addSubview(priceMinTextField)
//        
//        priceMaxTextField = UITextField()
//        priceMaxTextField.translatesAutoresizingMaskIntoConstraints = false
//        priceMaxTextField.placeholder = "Max Price"
//        priceMaxTextField.borderStyle = .roundedRect
//        priceMaxTextField.keyboardType = .numberPad
//        view.addSubview(priceMaxTextField)
//        
//        // --- Setup Apply Filter button ---
//        applyButton = UIButton(type: .system)
//        applyButton.translatesAutoresizingMaskIntoConstraints = false
//        applyButton.setTitle("Apply Filter", for: .normal)
//        applyButton.addTarget(self, action: #selector(applyFilterAction), for: .touchUpInside)
//        view.addSubview(applyButton)
//        
//        // --- Layout constraints ---
//        NSLayoutConstraint.activate([
//            // Collection view at top
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.heightAnchor.constraint(equalToConstant: 80),
//            
//            // Price text fields below collection view
//            priceMinTextField.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
//            priceMinTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            priceMinTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            priceMinTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            priceMaxTextField.topAnchor.constraint(equalTo: priceMinTextField.bottomAnchor, constant: 10),
//            priceMaxTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            priceMaxTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            priceMaxTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Apply button at the bottom
//            applyButton.topAnchor.constraint(equalTo: priceMaxTextField.bottomAnchor, constant: 20),
//            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            applyButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//    }
//    
//    @objc private func applyFilterAction() {
//        // Create a ProductFilter using values from UI
//        let filter = ProductFilter(title: nil,
//                                   priceMin: Double(priceMinTextField.text ?? ""),
//                                   priceMax: Double(priceMaxTextField.text ?? ""),
//                                   categoryId: selectedCategoryId,
//                                   offset: 0,
//                                   limit: 10)
//        // Instantiate the network configuration for filtering
//        let config = ProductNetworkConfig.filteredProducts(title: filter.title,
//                                                           priceMin: filter.priceMin,
//                                                           priceMax: filter.priceMax,
//                                                           categoryId: filter.categoryId,
//                                                           offset: filter.offset,
//                                                           limit: filter.limit)
//        // Construct the full URL and print it
//        let fullURL = "https://api.escuelajs.co/api/v1/" + config.path + config.endPoint
//        print("Full URL: \(fullURL)")
//        
//        // Pass the filter back using the onApplyFilter closure
//        onApplyFilter?(filter)
//        dismiss(animated: true)
//    }
//
//}

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

//extension FilterViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return categories.count  // assuming you have a categories array
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
//            return UICollectionViewCell()
//        }
//        let category = categories[indexPath.item]
//        cell.configure(with: category)
//        return cell
//    }
//}
//
//extension FilterViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // Handle selection of category
//        let category = categories[indexPath.item]
//        selectedCategoryId = category.id
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//            return CGSize(
//                width: (popular_brands[indexPath.item].size(
//                    withAttributes:
//                        [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width) + 25,
//                    height: 40
//                )
//        }
//}

//class FilterViewController: UIViewController {
//    
//    // Closure to pass the selected filter back
//    var onApplyFilter: ((ProductFilter) -> Void)?
//    
//    // Collection view for categories with custom layout
//    private var collectionView: UICollectionView!
//    
//    // Two text fields for price range input
//    private var priceMinTextField: UITextField!
//    private var priceMaxTextField: UITextField!
//    
//    // Apply Filter button
//    private var applyButton: UIButton!
//    
//    // Sample categories – replace with real data if needed
//    private let categories: [Category] = [
//        Category(id: 1, name: "Clothes", image: ""),
//        Category(id: 2, name: "Electronics", image: ""),
//        Category(id: 3, name: "Home", image: ""),
//        Category(id: 4, name: "Toys", image: "")
//    ]
//    
//    // Currently selected category id (if any)
//    private var selectedCategoryId: Int?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        setupUI()
//    }
//    
//    private func setupUI() {
//        // --- Setup category collection view with custom layout ---
//        let layout = CardFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
//        layout.minimumInteritemSpacing = 15
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .white
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
//        view.addSubview(collectionView)
//        
//        // --- Setup price text fields ---
//        priceMinTextField = UITextField()
//        priceMinTextField.translatesAutoresizingMaskIntoConstraints = false
//        priceMinTextField.placeholder = "Min Price"
//        priceMinTextField.borderStyle = .roundedRect
//        priceMinTextField.keyboardType = .numberPad
//        view.addSubview(priceMinTextField)
//        
//        priceMaxTextField = UITextField()
//        priceMaxTextField.translatesAutoresizingMaskIntoConstraints = false
//        priceMaxTextField.placeholder = "Max Price"
//        priceMaxTextField.borderStyle = .roundedRect
//        priceMaxTextField.keyboardType = .numberPad
//        view.addSubview(priceMaxTextField)
//        
//        // --- Setup Apply Filter button ---
//        applyButton = UIButton(type: .system)
//        applyButton.translatesAutoresizingMaskIntoConstraints = false
//        applyButton.setTitle("Apply Filter", for: .normal)
//        applyButton.addTarget(self, action: #selector(applyFilterAction), for: .touchUpInside)
//        view.addSubview(applyButton)
//        
//        // --- Layout constraints ---
//        NSLayoutConstraint.activate([
//            // Collection view at top
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.heightAnchor.constraint(equalToConstant: 80),
//            
//            // Price text fields below collection view
//            priceMinTextField.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
//            priceMinTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            priceMinTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            priceMinTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            priceMaxTextField.topAnchor.constraint(equalTo: priceMinTextField.bottomAnchor, constant: 10),
//            priceMaxTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            priceMaxTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            priceMaxTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Apply button at the bottom
//            applyButton.topAnchor.constraint(equalTo: priceMaxTextField.bottomAnchor, constant: 20),
//            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            applyButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//    }
//    
//    @objc private func applyFilterAction() {
//        // Create a ProductFilter using values from UI
//        let filter = ProductFilter(
//            title: nil,
//            priceMin: Double(priceMinTextField.text ?? ""),
//            priceMax: Double(priceMaxTextField.text ?? ""),
//            categoryId: selectedCategoryId,
//            offset: 0,
//            limit: 10
//        )
//        // (Optional) Print full URL for debugging:
//        let config = ProductNetworkConfig.filteredProducts(
//            title: filter.title,
//            priceMin: filter.priceMin,
//            priceMax: filter.priceMax,
//            categoryId: filter.categoryId,
//            offset: filter.offset,
//            limit: filter.limit
//        )
//        let fullURL = "https://api.escuelajs.co/api/v1/" + config.path + config.endPoint
//        print("Full URL: \(fullURL)")
//        
//        onApplyFilter?(filter)
//        dismiss(animated: true)
//    }
//}
//
//extension FilterViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return categories.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier,
//                                                            for: indexPath) as? CategoryCell else {
//            return UICollectionViewCell()
//        }
//        let category = categories[indexPath.item]
//        cell.configure(with: category)
//        return cell
//    }
//}
//
//extension FilterViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let category = categories[indexPath.item]
//        selectedCategoryId = category.id
//    }
//    
//    // Dynamic sizing based on text content.
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let category = categories[indexPath.item]
//        let text = category.name
//        let font = UIFont.systemFont(ofSize: 14)
//        let width = text.size(withAttributes: [NSAttributedString.Key.font: font]).width + 25
//        return CGSize(width: width, height: 40)
//    }
//}
