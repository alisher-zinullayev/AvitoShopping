//
//  ShoppingCartViewController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import UIKit

final class ShoppingCartViewController: UIViewController {
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ShoppingCartCell.self, forCellReuseIdentifier: ShoppingCartCell.identifier)
        return tv
    }()
    
    private let bottomActionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let deleteAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Удалить все элементы", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Оформить заказ", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private var cartItems: [ProductCD] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Корзина Покупок"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                              target: self,
                                                              action: #selector(shareCart))
        setupBottomActionView()
        setupTableView()
        addButtonTargets()
        fetchCartItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCartItems()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomActionView.topAnchor)
        ])
    }
    
    private func setupBottomActionView() {
        view.addSubview(bottomActionView)
        NSLayoutConstraint.activate([
            bottomActionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomActionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomActionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomActionView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        bottomActionView.addSubview(deleteAllButton)
        bottomActionView.addSubview(checkoutButton)
        NSLayoutConstraint.activate([
            deleteAllButton.leadingAnchor.constraint(equalTo: bottomActionView.leadingAnchor, constant: 16),
            deleteAllButton.centerYAnchor.constraint(equalTo: bottomActionView.centerYAnchor),
            deleteAllButton.heightAnchor.constraint(equalToConstant: 44),
            deleteAllButton.trailingAnchor.constraint(equalTo: bottomActionView.centerXAnchor, constant: -8),
            
            checkoutButton.leadingAnchor.constraint(equalTo: bottomActionView.centerXAnchor, constant: 8),
            checkoutButton.trailingAnchor.constraint(equalTo: bottomActionView.trailingAnchor, constant: -16),
            checkoutButton.centerYAnchor.constraint(equalTo: bottomActionView.centerYAnchor),
            checkoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func addButtonTargets() {
        deleteAllButton.addTarget(self, action: #selector(deleteAllTapped), for: .touchUpInside)
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
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
    
    @objc private func deleteAllTapped() {
        CoreDataManager.shared.clearCart()
        fetchCartItems()
    }
    
    @objc private func checkoutTapped() {
        let alert = UIAlertController(title: "Оформить заказ",
                                      message: "Приступать к оформлению заказа?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { [weak self] _ in
            self?.deleteAllTapped()
        }))
        present(alert, animated: true)
    }
}

extension ShoppingCartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingCartCell.identifier,
                                                       for: indexPath) as? ShoppingCartCell else {
            return UITableViewCell()
        }
        let item = cartItems[indexPath.row]
        cell.configure(with: item)
        cell.onQuantityChange = { [weak self] newQuantity in
            CoreDataManager.shared.updateCartItemQuantity(cartItem: item, newQuantity: newQuantity)
            self?.fetchCartItems()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = cartItems[indexPath.row]
            CoreDataManager.shared.deleteCartItem(cartItem: item)
            cartItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ShoppingCartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ShoppingCartViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        let item = cartItems[indexPath.row]
        let itemProvider = NSItemProvider(object: "\(item.productId)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension ShoppingCartViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView,
                   performDropWith coordinator: UITableViewDropCoordinator) {
        guard coordinator.proposal.operation == .move,
              let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        coordinator.items.forEach { dropItem in
            if let sourceIndexPath = dropItem.sourceIndexPath,
               let cartItem = dropItem.dragItem.localObject as? ProductCD {
                tableView.performBatchUpdates({
                    cartItems.remove(at: sourceIndexPath.row)
                    cartItems.insert(cartItem, at: destinationIndexPath.row)
                    tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                })
                for (index, item) in cartItems.enumerated() {
                    CoreDataManager.shared.updateCartItemPosition(cartItem: item, newPosition: index + 1)
                }
                coordinator.drop(dropItem.dragItem, toRowAt: destinationIndexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}
