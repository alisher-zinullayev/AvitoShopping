//
//  CustomLabel.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import UIKit

final class CustomLabel: UILabel {
    init(text: String, font: UIFont = UIFont.boldSystemFont(ofSize: 20), textAlignment: NSTextAlignment = .left) {
        super.init(frame: .zero)
        self.text = text
        self.font = font
        self.textAlignment = textAlignment
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
