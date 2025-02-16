//
//  RecentSearchManager.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import Foundation

final class RecentSearchManager {
    static let shared = RecentSearchManager()
    private let key = "recentSearches"
    private let maxCount = 5

    private init() {}

    func addSearchQuery(_ query: String) {
        var queries = getRecentSearches()
        queries.removeAll(where: { $0.caseInsensitiveCompare(query) == .orderedSame })
        queries.insert(query, at: 0)
        if queries.count > maxCount {
            queries = Array(queries.prefix(maxCount))
        }
        UserDefaults.standard.set(queries, forKey: key)
    }

    func getRecentSearches() -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}
