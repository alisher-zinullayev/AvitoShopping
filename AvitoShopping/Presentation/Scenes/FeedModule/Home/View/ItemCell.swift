//
//  ItemCell.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import UIKit

class ItemCell: UICollectionViewCell {
    static let identifier = String(describing: ItemCell.self)
    
//    var onFavoriteTapped: (() -> Void)?
    var onAddToCartTapped: (() -> Void)?
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
//    private let likeButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//        button.tintColor = .gray
//        button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        button.layer.cornerRadius = 20
//        button.clipsToBounds = true
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()

    private let naming: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
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
        label.numberOfLines = 2
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellAppearance() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
//        contentView.addSubview(likeButton)
        contentView.addSubview(naming)
        contentView.addSubview(info)
        contentView.addSubview(price)
        contentView.addSubview(addButton)

        imageView.layer.cornerRadius = 14
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
//        likeButton.addTarget(self, action: #selector(favoriteAction), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addToCartAction), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            
//            likeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
//            likeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
//            likeButton.widthAnchor.constraint(equalToConstant: 40),
//            likeButton.heightAnchor.constraint(equalToConstant: 40),
            
            naming.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            naming.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            naming.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            info.topAnchor.constraint(equalTo: naming.bottomAnchor, constant: 5),
            info.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            info.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            price.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 8),
            price.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            addButton.centerYAnchor.constraint(equalTo: price.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
//    @objc private func favoriteAction() {
//        onFavoriteTapped?()
//        likeButton.tintColor = (likeButton.tintColor == .red) ? .gray : .red
//    }
    
    @objc private func addToCartAction() {
        onAddToCartTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
//        likeButton.tintColor = .gray
    }
    
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
