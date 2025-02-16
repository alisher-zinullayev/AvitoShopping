//
//  ProductCD+CoreDataProperties.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//
//

import Foundation
import CoreData


extension ProductCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductCD> {
        return NSFetchRequest<ProductCD>(entityName: "ProductCD")
    }

    @NSManaged public var dateAdded: Date?
    @NSManaged public var imageUrl: String?
    @NSManaged public var position: Int64
    @NSManaged public var price: Double
    @NSManaged public var productId: Int64
    @NSManaged public var quantity: Int64
    @NSManaged public var title: String?

}

extension ProductCD : Identifiable {

}
