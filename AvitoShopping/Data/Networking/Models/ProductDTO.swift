//
//  ProductDTO.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: Category
    let images: [String]
}

struct Category: Decodable {
    let id: Int
    let name: String
    let image: String
}
