//
//  FilterViewControlle.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 14.02.2025.
//

import UIKit

class FilterViewController: UIViewController {

    var onApplyFilter: ((ProductFilter) -> Void)?

    // MARK: - UI Elements

    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Title"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let categoriesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "All Categories"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var collectionView: UICollectionView!
    
    private let pricesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Prices"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var priceMinTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Min Price"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private var priceMaxTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Max Price"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var pricesStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priceMinTextField, priceMaxTextField])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Filter", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(applyFilterAction), for: .touchUpInside)
        return button
    }()
    
    // Sample categories – replace with your real data as needed.
    private let categories: [Category] = [
        Category(id: 1, name: "Clothes", image: ""),
        Category(id: 2, name: "Electronics", image: ""),
        Category(id: 3, name: "Home", image: ""),
        Category(id: 4, name: "Toys", image: "")
    ]
    
    // Currently selected category id (if any)
    private var selectedCategoryId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Filters"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        // Add title text field for filtering by title
        view.addSubview(titleTextField)
        
        // Add "All Categories" title
        view.addSubview(categoriesTitleLabel)
        
        // Setup collection view with custom layout (using your CardFlowLayout)
        let layout = CardFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 15
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        view.addSubview(collectionView)
        
        // Add "Prices" title label and prices stack view
        view.addSubview(pricesTitleLabel)
        view.addSubview(pricesStackView)
        
        // Add Apply Filter button
        view.addSubview(applyButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title text field at the very top
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // "All Categories" title below title text field
            categoriesTitleLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            categoriesTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Collection view below the categories title
            collectionView.topAnchor.constraint(equalTo: categoriesTitleLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 80),
            
            // "Prices" title below collection view
            pricesTitleLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            pricesTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pricesTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Prices stack view (side by side text fields) below prices title
            pricesStackView.topAnchor.constraint(equalTo: pricesTitleLabel.bottomAnchor, constant: 10),
            pricesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pricesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pricesStackView.heightAnchor.constraint(equalToConstant: 40),
            
            // Apply Filter button below the prices stack view
            applyButton.topAnchor.constraint(equalTo: pricesStackView.bottomAnchor, constant: 20),
            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            applyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func applyFilterAction() {
        let filter = ProductFilter(
            title: titleTextField.text,
            priceMin: Double(priceMinTextField.text ?? ""),
            priceMax: Double(priceMaxTextField.text ?? ""),
            categoryId: selectedCategoryId,
            offset: 0,
            limit: 10
        )
        
        onApplyFilter?(filter)
        dismiss(animated: true)
    }
}

extension FilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.item]
        cell.configure(with: category)
        return cell
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        selectedCategoryId = category.id
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = categories[indexPath.item]
        let text = category.name
        let font = UIFont.systemFont(ofSize: 14)
        let width = text.size(withAttributes: [NSAttributedString.Key.font: font]).width + 25
        return CGSize(width: width, height: 40)
    }
}
