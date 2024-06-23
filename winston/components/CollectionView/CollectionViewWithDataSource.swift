//
//  CollectionViewWithDataSource.swift
//  winston
//
//  Created by Igor Marcossi on 14/04/24.
//

import SwiftUI

final class CollectionViewWithDataSource<SectionIdentifierType, ItemIdentifierType>: UICollectionView
where

SectionIdentifierType: Hashable & Sendable,
ItemIdentifierType: Hashable & Sendable {
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    private let cellProvider: DataSource.CellProvider
    
    private let updateQueue: DispatchQueue = DispatchQueue(
        label: "com.collectionview.update",
        qos: .userInteractive)
    
    private lazy var collectionDataSource: DataSource = {
        DataSource(
            collectionView: self,
            cellProvider: cellProvider
        )
    }()
    
    init(frame: CGRect,
         collectionViewLayout: UICollectionViewLayout,
         collectionViewConfiguration: ((UICollectionView) -> Void),
         cellProvider: @escaping DataSource.CellProvider,
         supplementaryViewProvider: DataSource.SupplementaryViewProvider?) {
        
        self.cellProvider = cellProvider
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        collectionViewConfiguration(self)
        
        collectionDataSource.supplementaryViewProvider = supplementaryViewProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(_ snapshot: Snapshot,
               animatingDifferences: Bool = true,
               completion: (() -> Void)? = nil) {
        
        updateQueue.async { [weak self] in
            self?.collectionDataSource.apply(
                snapshot,
                animatingDifferences: animatingDifferences,
                completion: completion
            )
        }
    }
}
