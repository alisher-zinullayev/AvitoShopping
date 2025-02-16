//
//  ShoppingCartViewController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import UIKit

class ShoppingCartViewController: UIViewController {
    private var tableView: UITableView!
    private var cartItems: [ProductCD] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Shopping Cart"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(shareCart))
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCartItems()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ShoppingCartCell.self, forCellReuseIdentifier: ShoppingCartCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func fetchCartItems() {
        cartItems = CoreDataManager.shared.fetchCartItems()
        tableView.reloadData()
    }
    
    @objc private func shareCart() {
        let summary = CoreDataManager.shared.cartSummary()
        let activityVC = UIActivityViewController(activityItems: [summary], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

extension ShoppingCartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingCartCell.identifier, for: indexPath) as? ShoppingCartCell else {
            return UITableViewCell()
        }
        let item = cartItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

extension ShoppingCartViewController: UITableViewDelegate {
    // Optionally, support deleting items
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = cartItems[indexPath.row]
            CoreDataManager.shared.deleteCartItem(cartItem: item)
            cartItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

class ShoppingCartCell: UITableViewCell {
    static let identifier = "ShoppingCartCell"
    
    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "photo") // placeholder
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(quantityLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 60),
            productImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            quantityLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            quantityLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            quantityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with item: ProductCD) {
        titleLabel.text = item.title
        priceLabel.text = "Price: \(item.price)$"
        quantityLabel.text = "Quantity: \(item.quantity)"
        if let urlString = item.imageUrl, !urlString.isEmpty {
            productImageView.loadImage(from: urlString)
        } else {
            productImageView.image = UIImage(systemName: "photo")
        }
    }
}
