//
//  GalleryPageViewController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 16.02.2025.
//

import UIKit

final class GalleryPageViewController: UIViewController {
    let imageUrl: String
    private let imageView = UIImageView()
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupImageView()
    }
    
    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        imageView.loadImage(from: imageUrl)
    }
}

final class GalleryViewController: UIPageViewController {
    private let imageUrls: [String]
    private var currentIndex: Int
    
    init(imageUrls: [String], initialIndex: Int) {
        self.imageUrls = imageUrls
        self.currentIndex = initialIndex
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.dataSource = self
        self.delegate = self
        
        if let initialVC = pageFor(index: initialIndex) {
            setViewControllers([initialVC], direction: .forward, animated: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Back", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 5
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func pageFor(index: Int) -> GalleryPageViewController? {
        guard index >= 0, index < imageUrls.count else { return nil }
        return GalleryPageViewController(imageUrl: imageUrls[index])
    }
}

extension GalleryViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? GalleryPageViewController,
              let index = imageUrls.firstIndex(of: currentVC.imageUrl) else { return nil }
        return pageFor(index: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? GalleryPageViewController,
              let index = imageUrls.firstIndex(of: currentVC.imageUrl) else { return nil }
        return pageFor(index: index + 1)
    }
}

extension GalleryViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed,
           let visibleVC = pageViewController.viewControllers?.first as? GalleryPageViewController,
           let index = imageUrls.firstIndex(of: visibleVC.imageUrl) {
            currentIndex = index
        }
    }
}
