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

