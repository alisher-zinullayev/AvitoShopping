//
//  CoreDataManager.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ShoppingCartModel")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error loading persistent store: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - CartItem CRUD Methods
    
    func createCartItem(productId: Int, title: String, price: Double, imageUrl: String, quantity: Int, position: Int, date: Date = Date()) {
        let cartItem = ProductCD(context: context)
        cartItem.productId = Int64(productId)
        cartItem.title = title
        cartItem.price = price
        cartItem.imageUrl = imageUrl
        cartItem.quantity = Int64(quantity)
        cartItem.position = Int64(position)
        cartItem.dateAdded = date
        saveContext()
    }
    
    func fetchCartItems() -> [ProductCD] {
        let fetchRequest: NSFetchRequest<ProductCD> = ProductCD.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching cart items: \(error)")
            return []
        }
    }
    
    func updateCartItemQuantity(cartItem: ProductCD, newQuantity: Int) {
        cartItem.quantity = Int64(newQuantity)
        saveContext()
    }
    
    func updateCartItemPosition(cartItem: ProductCD, newPosition: Int) {
        cartItem.position = Int64(newPosition)
        saveContext()
    }
    
    func deleteCartItem(cartItem: ProductCD) {
        context.delete(cartItem)
        saveContext()
    }
    
    func clearCart() {
        let items = fetchCartItems()
        items.forEach { context.delete($0) }
        saveContext()
    }
    
    func cartSummary() -> String {
        let items = fetchCartItems()
        guard !items.isEmpty else { return "Your shopping cart is empty." }
        var summary = "Shopping Cart:\n"
        for item in items {
            summary += "\(item.title ?? ""): \(item.quantity) x \(item.price)$\n"
        }
        return summary
    }
}
