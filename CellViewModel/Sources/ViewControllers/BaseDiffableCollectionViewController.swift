//
//  BaseDiffableCollectionViewController.swift
//  CellViewModel
//
//  Created by Anton Poltoratskyi on 5/12/19.
//  Copyright © 2019 Anton Poltoratskyi. All rights reserved.
//

import UIKit

open class BaseDiffableCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    private(set) open lazy var adapter = DiffableCollectionViewDataAdapter(collectionView: self._collectionView,
                                                                           inferModelTypes: self.automaticallyInferCellViewModelTypes)
    
    open var automaticallyInferCellViewModelTypes: Bool {
        return false
    }
    
    open var viewModels: [AnyCellViewModel.Type] {
        // must be implemented in subclasses
        return []
    }
    
    open var supplementaryModels: [AnySupplementaryViewModel.Type] {
        // must be implemented in subclasses
        return []
    }
    
    // MARK: - Views
    
    // must be set in subclasses
    open var _collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    open func setupUI() {
        _collectionView.delegate = self
        _collectionView.register(viewModels)
        _collectionView.register(supplementaryModels)
    }
    
    // MARK: - View Input
    
    open func setup(_ sections: [DiffableSection]) {
        adapter.update(data: sections, animated: false)
    }
    
    open func update(_ sections: [DiffableSection]) {
        adapter.update(data: sections, animated: true)
    }
    
    // MARK: - Collection View Delegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = adapter.itemModel(at: indexPath) as? InteractiveCellViewModel else {
            return
        }
        item.selectionHandler?()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return adapter.sectionModel(at: section).insets ?? .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return adapter.sectionModel(at: section).lineSpacing ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let maxWidth = collectionView.bounds.width
        let height = adapter
            .headerModel(in: section)
            .flatMap { $0.height(constrainedBy: maxWidth) }
            ?? 0
        
        return CGSize(width: maxWidth, height: height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let maxWidth = collectionView.bounds.width
        let height = adapter
            .footerModel(in: section)
            .flatMap { $0.height(constrainedBy: maxWidth) }
            ?? 0
        
        return CGSize(width: maxWidth, height: height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = collectionView.bounds.width
        
        let viewModel = adapter.itemModel(at: indexPath)
        let height = viewModel.height(constrainedBy: maxWidth) ?? 0
        
        return CGSize(width: maxWidth, height: height)
    }
}