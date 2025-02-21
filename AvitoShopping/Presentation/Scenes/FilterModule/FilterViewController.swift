//
//  FilterViewControlle.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 14.02.2025.
//

import UIKit

final class FilterViewController: UIViewController {
    var onApplyFilter: ((ProductFilter) -> Void)?

    private var selectedCategoryId: Int?
    private let viewModel = FilterViewModel()
    
    private let titleTextField = CustomTextField(placeholder: "Продукт")
    private let categoriesTitleLabel = CustomLabel(text: "Все категории")
    
    private lazy var collectionView: UICollectionView = {
        let layout = CardFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 15
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        return cv
    }()
    
    private let pricesTitleLabel = CustomLabel(text: "Цены")
    private let priceMinTextField = CustomTextField(placeholder: "Мин цена", keyboardType: .numberPad)
    private let priceMaxTextField = CustomTextField(placeholder: "Макс цена", keyboardType: .numberPad)
    
    private lazy var pricesStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priceMinTextField, priceMaxTextField])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var applyButton: UIButton = {
        return CustomButton(title: "Применить фильтр")
    }()
    
    private let categories: [Category] = [
        Category(id: 1, name: "Одежда", image: ""),
        Category(id: 2, name: "Электроника", image: ""),
        Category(id: 3, name: "Мебель", image: ""),
        Category(id: 4, name: "Обувь", image: "")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Фильтры"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .white
        setupUI()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == titleTextField {
            viewModel.title = textField.text
        } else if textField == priceMinTextField {
            viewModel.priceMin = textField.text
        } else if textField == priceMaxTextField {
            viewModel.priceMax = textField.text
        }
    }
    
    @objc private func applyFilterAction() {
        viewModel.selectedCategoryId = selectedCategoryId
        let filter = viewModel.currentFilter()
        onApplyFilter?(filter)
        dismiss(animated: true)
    }
}

extension FilterViewController {
    private func setupUI() {
        view.addSubview(titleTextField)
        view.addSubview(categoriesTitleLabel)
        view.addSubview(collectionView)
        view.addSubview(pricesTitleLabel)
        view.addSubview(pricesStackView)
        view.addSubview(applyButton)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            categoriesTitleLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            categoriesTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: categoriesTitleLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 80),
            
            pricesTitleLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            pricesTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pricesTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            pricesStackView.topAnchor.constraint(equalTo: pricesTitleLabel.bottomAnchor, constant: 10),
            pricesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pricesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pricesStackView.heightAnchor.constraint(equalToConstant: 40),
            
            applyButton.topAnchor.constraint(equalTo: pricesStackView.bottomAnchor, constant: 20),
            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            applyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        priceMinTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        priceMaxTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        applyButton.addTarget(self, action: #selector(applyFilterAction), for: .touchUpInside)
    }
}

extension FilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.item]
        cell.configure(with: category)
        return cell
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        selectedCategoryId = category.id
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = categories[indexPath.item]
        let text = category.name
        let font = UIFont.systemFont(ofSize: 14)
        let width = text.size(withAttributes: [NSAttributedString.Key.font: font]).width + 25
        return CGSize(width: width, height: 40)
    }
}
