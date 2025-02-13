//
//  Pagination.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

struct Pagination {
    var offset: Int = 0
    var limit: Int = 10
    var totalCount: Int?

    var isLimitReached: Bool {
        if let total = totalCount {
            return offset >= total
        }
        return false
    }
    
    mutating func nextPage() {
        offset += limit
    }
    
    mutating func reset() {
        offset = 0
    }
}

enum Page {
    case first
    case next
}
