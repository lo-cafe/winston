//
//  CustomList.swift
//  winston
//
//  Created by Igor Marcossi on 14/04/24.
//

import SwiftUI

struct CustomList: View {
    typealias Item = Int
    typealias Section = Int
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    @State var snapshot: Snapshot = {
        var initialSnapshot = Snapshot()
        initialSnapshot.appendSections([0])
        return initialSnapshot
    }()
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            CollectionView(
                snapshot: snapshot,
                collectionViewLayout: collectionViewLayout,
                cellProvider: cellProviderWithRegistration
            )
            .padding()
            
            Button(
                action: {
                    let itemsCount = snapshot.numberOfItems(inSection: 0)
                    snapshot.appendItems([itemsCount + 1], toSection: 0)
                }, label: {
                    Text("Add More Items")
                }
            )
        }
    }
    
    let cellRegistration: UICollectionView.CellRegistration = .hosting { (idx: IndexPath, item: Item) in
        Text("\(item)")
    }
}


extension CustomList {
    func collectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewFlowLayout()
    }
    
    func cellProviderWithRegistration(
        _ collectionView: UICollectionView,
        indexPath: IndexPath,
        item: Item
    ) -> UICollectionViewCell {
        
        collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item
        )
    }
}
