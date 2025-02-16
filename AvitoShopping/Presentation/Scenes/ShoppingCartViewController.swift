//
//  ShoppingCartViewController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import UIKit

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
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
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

extension ShoppingCartViewController: UITableViewDelegate { }

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
                // Update positions in Core Data.
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
