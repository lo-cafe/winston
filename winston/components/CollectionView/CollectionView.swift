//
//  CollectionView.swift
//  winston
//
//  Created by Igor Marcossi on 14/04/24.
//

import SwiftUI

extension CollectionView {
    typealias UIKitCollectionView = CollectionViewWithDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias DataSource =  UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    typealias UpdateCompletion = () -> Void
}

struct CollectionView<SectionIdentifierType, ItemIdentifierType>
where
SectionIdentifierType: Hashable & Sendable,
ItemIdentifierType: Hashable & Sendable {
    
    private let snapshot: Snapshot
    private let configuration: ((UICollectionView) -> Void)
    private let cellProvider: DataSource.CellProvider
    private let supplementaryViewProvider: DataSource.SupplementaryViewProvider?
    
    private let collectionViewLayout: () -> UICollectionViewLayout
    
    private(set) var collectionViewDelegate: (() -> UICollectionViewDelegate)?
    private(set) var animatingDifferences: Bool = true
    private(set) var updateCallBack: UpdateCompletion?
    
    init(snapshot: Snapshot,
         collectionViewLayout: @escaping () -> UICollectionViewLayout,
         configuration: @escaping ((UICollectionView) -> Void) = { _ in },
         cellProvider: @escaping  DataSource.CellProvider,
         supplementaryViewProvider: DataSource.SupplementaryViewProvider? = nil) {
        
        self.snapshot = snapshot
        self.configuration = configuration
        self.cellProvider = cellProvider
        self.supplementaryViewProvider = supplementaryViewProvider
        self.collectionViewLayout = collectionViewLayout
    }
}

extension CollectionView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIKitCollectionView {
        let collectionView = UIKitCollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout(),
            collectionViewConfiguration: configuration,
            cellProvider: cellProvider,
            supplementaryViewProvider: supplementaryViewProvider
        )
        
        let delegate = collectionViewDelegate?()
        collectionView.delegate = delegate
        return collectionView
    }
    
    func updateUIView(_ uiView: UIKitCollectionView,
                      context: Context) {
        uiView.apply(
            snapshot,
            animatingDifferences: animatingDifferences,
            completion: updateCallBack
        )
    }
}

extension CollectionView {
    func animateDifferences(_ animate: Bool) -> Self {
        var selfCopy = self
        selfCopy.animatingDifferences = animate
        return self
    }
    
    func onUpdate(_ perform: (() -> Void)?) -> Self {
        var selfCopy = self
        selfCopy.updateCallBack = perform
        return self
    }
    
    func collectionViewDelegate(_ makeDelegate: @escaping (() -> UICollectionViewDelegate)) -> Self {
        var selfCopy = self
        selfCopy.collectionViewDelegate = makeDelegate
        return self
    }
}

extension UICollectionView.CellRegistration {

    static func hosting<Content: View, Item>(
        content: @escaping (IndexPath, Item) -> Content) -> UICollectionView.CellRegistration<UICollectionViewCell, Item> {

        UICollectionView.CellRegistration { cell, indexPath, item in

            cell.contentConfiguration = UIHostingConfiguration {
                content(indexPath, item)
            }
        }
    }
}
