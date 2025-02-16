//
//  ProductDetailViewModel.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 16.02.2025.
//

import Foundation

final class ProductDetailViewModel: ObservableObject {
    private let productId: String
    private let fetchProductDetailUseCase: FetchProductDetailUseCaseProtocol
    private let addToCartUseCase: AddToCartUseCaseProtocol
    private let checkProductInCartUseCase: CheckProductInCartUseCaseProtocol
    
    var onStateChange: ((ProductDetailViewState) -> Void)?
    
    private(set) var state: ProductDetailViewState = .idle {
        didSet { onStateChange?(state) }
    }
    
    private(set) var product: ProductDTO?
    
    init(productId: String,
         fetchProductDetailUseCase: FetchProductDetailUseCaseProtocol,
         addToCartUseCase: AddToCartUseCaseProtocol,
         checkProductInCartUseCase: CheckProductInCartUseCaseProtocol) {
        self.productId = productId
        self.fetchProductDetailUseCase = fetchProductDetailUseCase
        self.addToCartUseCase = addToCartUseCase
        self.checkProductInCartUseCase = checkProductInCartUseCase
    }
    
    func handle(_ event: ProductDetailViewEvent) {
        switch event {
        case .onAppear:
            loadProductDetail()
        case .onAddToCart:
            addToCart()
        case .onShare:
            break
        }
    }
    
    private func loadProductDetail() {
        state = .loading
        Task {
            do {
                let fetchedProduct = try await fetchProductDetailUseCase.execute(productId: productId)
                self.product = fetchedProduct
                let isInCart = try await checkProductInCartUseCase.execute(productId: productId)
                state = .loaded(product: fetchedProduct, isInCart: isInCart)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    private func addToCart() {
        guard let product = product else { return }
        Task {
            do {
                try addToCartUseCase.execute(product: product)
                state = .loaded(product: product, isInCart: true)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}

extension ProductDetailViewModel {
    var shareText: String? {
        if case .loaded(let product, _) = state {
            return """
            \(product.title)
            Price: \(product.price)$
            \(product.description)
            """
        }
        return nil
    }
}
