//
//  ItemCell.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import UIKit

class ItemCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ItemCell.self)
    
    // MARK: - Subviews
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .gray
        button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let naming: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1 // Only 1 line
        label.lineBreakMode = .byTruncatingTail
        label.text = "Casual Brown"
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let info: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2 // Only 2 lines
        label.lineBreakMode = .byTruncatingTail
        label.text = "Lorem ipsum is a placeholder text commonly used..."
        label.textColor = .lightGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let price: UILabel = {
        let label = UILabel()
        label.text = "$23.09"
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 10)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Callbacks
    
    var onFavoriteTapped: (() -> Void)?
    var onAddToCartTapped: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCellAppearance() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(naming)
        contentView.addSubview(info)
        contentView.addSubview(price)
        contentView.addSubview(addButton)

        // Round only the top corners of imageView to match cell’s corner radius
        imageView.layer.cornerRadius = 14
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Add button target
        likeButton.addTarget(self, action: #selector(favoriteAction), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addToCartAction), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 1. Image at the top
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // Choose a fixed height or a ratio
            // For example, half of the cell's height:
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            // or a fixed height:
            // imageView.heightAnchor.constraint(equalToConstant: 120),
            
            // 2. Like button at top-right of the image
            likeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // 3. naming label
            naming.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            naming.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            naming.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // 4. info label
            info.topAnchor.constraint(equalTo: naming.bottomAnchor, constant: 5),
            info.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            info.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // 5. price label
            price.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 8),
            price.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            // 6. Add button
            addButton.centerYAnchor.constraint(equalTo: price.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func favoriteAction() {
        onFavoriteTapped?()
        // Example: toggle tint color
        likeButton.tintColor = (likeButton.tintColor == .red) ? .gray : .red
    }
    
    @objc private func addToCartAction() {
        onAddToCartTapped?()
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        likeButton.tintColor = .gray
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: ProductItemViewModel) {
        naming.text = viewModel.title
        info.text = viewModel.description
        price.text = String(format: "$%.2f", viewModel.price)
        
        if !viewModel.imageUrl.isEmpty {
            imageView.loadImage(from: viewModel.imageUrl)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
}



//class ItemCell: UICollectionViewCell {
//    static let reuseIdentifier = String(describing: ItemCell.self)
//
//    private lazy var likeButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//        button.tintColor = .gray
//        button.layer.cornerRadius = 25
//        button.clipsToBounds = true
//        button.addTarget(self, action: #selector(favoriteAction), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let naming: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 1
//        label.text = "Casual Brown"
//        label.textColor = .black
//        label.font = .systemFont(ofSize: 18, weight: .bold)
//        label.textAlignment = .left
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        imageView.image = UIImage(systemName: "photo")
//    }
//    
//    private let imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFit
//        iv.image = UIImage(systemName: "gamecontroller.fill")
//        iv.clipsToBounds = true
//        iv.layer.cornerRadius = 10
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        return iv
//    }()
//    
//    private let info: UILabel = {
//        let label = UILabel()
//        label.text = "Lorem ipsum is a placeholder text commonly used"
//        label.numberOfLines = 2
//        label.textColor = .lightGray
//        label.textAlignment = .left
//        label.font = .systemFont(ofSize: 12, weight: .regular)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let price: UILabel = {
//        let label = UILabel()
//        label.text = "$23.09"
//        label.textColor = .systemBlue
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private lazy var addButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Add", for: .normal)
//        button.titleLabel?.font = .boldSystemFont(ofSize: 10)
//        button.setTitleColor(.black, for: .normal)
//        button.backgroundColor = .systemBlue.withAlphaComponent(0.3)
//        button.layer.cornerRadius = 15
//        button.clipsToBounds = true
//        button.addTarget(self, action: #selector(addToCartAction), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    var onFavoriteTapped: (() -> Void)?
//    var onAddToCartTapped: (() -> Void)?
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//        contentView.backgroundColor = .secondarySystemBackground
//        contentView.layer.cornerRadius = 8
//        contentView.layer.masksToBounds = true
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews() {
//        contentView.layer.cornerRadius = 14
//        contentView.backgroundColor = .systemGray6
//        
//        contentView.addSubview(likeButton)
//        contentView.addSubview(imageView)
//        contentView.addSubview(naming)
//        contentView.addSubview(info)
//        contentView.addSubview(price)
//        contentView.addSubview(addButton)
//        
//        NSLayoutConstraint.activate([
//            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            likeButton.widthAnchor.constraint(equalToConstant: 40),
//            likeButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            imageView.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 8),
//            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
//            imageView.heightAnchor.constraint(equalToConstant: 80), // выберите подходящее число
//            
//            naming.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
//            naming.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            naming.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            
//            info.topAnchor.constraint(equalTo: naming.bottomAnchor, constant: 5),
//            info.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            info.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            
//            price.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 10),
//            price.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            
//            addButton.centerYAnchor.constraint(equalTo: price.centerYAnchor),
//            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            addButton.widthAnchor.constraint(equalToConstant: 60),
//            addButton.heightAnchor.constraint(equalToConstant: 30)
//        ])
//    }
//    
//    @objc private func favoriteAction() {
//        onFavoriteTapped?()
//        likeButton.tintColor = .red
//    }
//    
//    @objc private func addToCartAction() {
//        onAddToCartTapped?()
//    }
//    
//    func configure(with viewModel: ProductItemViewModel) {
//        naming.text = viewModel.title
//        info.text = viewModel.description
//        price.text = String(format: "$%.2f", viewModel.price)
//        
//        if !viewModel.imageUrl.isEmpty {
//            imageView.loadImage(from: viewModel.imageUrl)
//        } else {
//            imageView.image = UIImage(systemName: "photo")
//        }
//    }
//}
