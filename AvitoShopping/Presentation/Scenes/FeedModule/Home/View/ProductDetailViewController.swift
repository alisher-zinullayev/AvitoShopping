//
//  ProductDetailViewController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import UIKit

final class ProductDetailViewController: UIViewController {
    private let viewModel: ProductDetailViewModel
    
    private var imagesCollectionView: UICollectionView!
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let categoryLabel = UILabel()
    private let addToCartButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "Product Detail"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupImagesCollectionView()
        setupLabels()
        setupButtons()
        layoutUI()
        bindViewModel()
        viewModel.handle(.onAppear)
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleState(state)
            }
        }
    }
    
    private func handleState(_ state: ProductDetailViewState) {
        switch state {
        case .idle, .loading:
            break
        case .loaded(let product, let isInCart):
            titleLabel.text = product.title
            descriptionLabel.text = product.description
            priceLabel.text = "Price: \(product.price)$"
            categoryLabel.text = "Category: \(product.category.name)"
            let buttonTitle = isInCart ? "Go to Cart" : "Add to Cart"
            addToCartButton.setTitle(buttonTitle, for: .normal)
            imagesCollectionView.reloadData()
        case .error(let message):
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func setupImagesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        imagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        imagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        imagesCollectionView.backgroundColor = .clear
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        imagesCollectionView.showsHorizontalScrollIndicator = false
        imagesCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        view.addSubview(imagesCollectionView)
    }
    
    private func setupLabels() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        priceLabel.font = UIFont.systemFont(ofSize: 18)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(priceLabel)
        
        categoryLabel.font = UIFont.systemFont(ofSize: 18)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryLabel)
    }
    
    private func setupButtons() {
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.backgroundColor = .systemBlue
        addToCartButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        addToCartButton.layer.cornerRadius = 8
        addToCartButton.clipsToBounds = true
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        view.addSubview(addToCartButton)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = .systemOrange
        shareButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        shareButton.layer.cornerRadius = 8
        shareButton.clipsToBounds = true
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        view.addSubview(shareButton)
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            imagesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imagesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: imagesCollectionView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            categoryLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            addToCartButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            addToCartButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            addToCartButton.heightAnchor.constraint(equalToConstant: 44),
            addToCartButton.widthAnchor.constraint(equalToConstant: 150),
            
            shareButton.centerYAnchor.constraint(equalTo: addToCartButton.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            shareButton.heightAnchor.constraint(equalToConstant: 44),
            shareButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc private func addToCartTapped() {
        viewModel.handle(.onAddToCart)
    }
    
    @objc private func shareTapped() {
        guard case .loaded(let product, _) = viewModel.state else { return }
        let shareText = """
        \(product.title)
        Price: \(product.price)$
        \(product.description)
        """
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

extension ProductDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard case .loaded(let product, _) = viewModel.state else { return 0 }
        return product.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier,
                                                            for: indexPath) as? ImageCell,
              case .loaded(let product, _) = viewModel.state else {
            return UICollectionViewCell()
        }
        let imageUrl = product.images[indexPath.item]
        cell.configure(with: imageUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width * 0.8
        return CGSize(width: width, height: width)
    }
}

extension ProductDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = viewModel.product else { return }
        let cleanUrls = product.images.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "[]\"")) }
        let galleryVC = GalleryViewController(imageUrls: cleanUrls, initialIndex: indexPath.item)
        galleryVC.modalPresentationStyle = .fullScreen
        present(galleryVC, animated: true)
    }
}
