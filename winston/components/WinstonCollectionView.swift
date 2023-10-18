//
// (See usage below implementation)
//
// SwiftUI `CollectionView` type implemented with UIKit's UICollectionView under the hood.
// Requires `UIViewControllerRepresentable` over `UIViewRepresentable` as the type that allows
// for SwiftUI `View`s to be added as subviews of UIKit `UIView`s at all bridges this gap as
// the `UIHostingController`.
//
// Not battle-tested yet, but seems to be working well so far.
// Expect changes.

import SwiftUI
import IGListKit
import UIKit
import Defaults

private enum GenericSection: Int {
  case main
}

struct WinstonCollectionView<CellContent: View, T: GenericRedditEntityDataType, B: Hashable>: UIViewControllerRepresentable {
  
  typealias Data = GenericRedditEntity<T, B>
  typealias Collection = [Data]
  typealias ContentForData = (Data, UIViewController, Int, Int) -> CellContent
  typealias ScrollDirection = UICollectionView.ScrollDirection
  typealias SizeForData = (Data) -> CGSize
  typealias CustomSizeForData = (UICollectionView, UICollectionViewLayout, Data) -> CGSize
  typealias RawCustomize = (UICollectionView) -> Void
  
  enum ContentSize {
    case fixed(CGSize)
    case variable(SizeForData)
    case crossAxisFilled(mainAxisLength: CGFloat)
    case custom(CustomSizeForData)
  }
  
  struct ItemSpacing : Hashable {
    var mainAxisSpacing: CGFloat
    var crossAxisSpacing: CGFloat
  }
  
  fileprivate let collection: Collection
  fileprivate let contentForData: ContentForData
  fileprivate let scrollDirection: ScrollDirection
  fileprivate let contentSize: ContentSize
  fileprivate let itemSpacing: ItemSpacing
  fileprivate let sectionInset: EdgeInsets
  fileprivate let rawCustomize: RawCustomize?
  
  init(
    collection: Collection,
    scrollDirection: ScrollDirection = .vertical,
    contentSize: ContentSize,
    itemSpacing: ItemSpacing = ItemSpacing(mainAxisSpacing: 0, crossAxisSpacing: 0),
    sectionInset: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
    rawCustomize: RawCustomize? = nil,
    @ViewBuilder contentForData: @escaping ContentForData) where Collections == [Collection]
  {
    self.init(
      collections: [collection],
      scrollDirection: scrollDirection,
      contentSize: contentSize,
      itemSpacing: itemSpacing,
      sectionInset: sectionInset,
      rawCustomize: rawCustomize,
      contentForData: contentForData)
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(view: self)
  }
  
  func makeUIViewController(context: Context) -> CollectionViewController {
    let coordinator = context.coordinator
    let viewController = CollectionViewController(scrollDirection: self.scrollDirection, inset: self.sectionInset, coordinator: context.coordinator)
    viewController.collectionView.delegate = coordinator
    coordinator.view = self
    coordinator.collectionController = viewController
    coordinator.configureDataSource()
//    coordinator.snapshotForCurrentState()
    //    coordinator.snap
    //    self.rawCustomize?(viewController.collectionView)
    return viewController
  }
  
  func updateUIViewController(_ uiViewController: CollectionViewController, context: Context) {
    context.coordinator.view = self
    context.coordinator.snapshotForCurrentState()
    //    context.coordinator.itemsDataSource = uiViewController.data
    //    if context.coordinator.data.count != collections[0].count {
    //      if collections.count > 0 {
//    uiViewController.collectionView.reloadData()
    //    }
  }
}

extension WinstonCollectionView {
  
  final class Coordinator : NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, IGListSectionController {
    
    fileprivate var view: WinstonCollectionView
    fileprivate var collectionController: CollectionViewController?
    
    
//    var registration: UICollectionView.CellRegistration<UICollectionViewListCell, Data>!
//    fileprivate var itemsDataSource: UICollectionViewDiffableDataSource<GenericSection, Data.ID>!
    
    init(view: WinstonCollectionView) {
      self.view = view
    }
    
//    func configureDataSource() {
//      let itemCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Data> { cell, indexPath, item in
//        let contentConfiguration = UIHostingConfiguration { self.view.contentForData(item, self.collectionController!, indexPath.item, self.view.collections[0].count) }
//        cell.contentConfiguration = contentConfiguration
//      }
//
//      itemsDataSource = UICollectionViewDiffableDataSource(collectionView: self.collectionController!.collectionView) {
//        collectionView, indexPath, identifier -> UICollectionViewCell in
//        let item = self.view.collections[0].first { $0.id == identifier}
//        var cell = collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: item)
//        return cell
//      }
//    }
    
//    func snapshotForCurrentState() {
//      let itemsIds: [Data.ID] = self.view.collections[0].map { $0.id }
//
//      var snapshot = NSDiffableDataSourceSnapshot<GenericSection, Data.ID>()
//      snapshot.appendSections([.main])
//      snapshot.appendItems(itemsIds, toSection: .main)
//      itemsDataSource.applySnapshotUsingReloadData(snapshot)
//    }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//      //      collectionView.gestureRecognizers?.forEach { (recognizer) in
//      //        if let longPressRecognizer = recognizer as? UILongPressGestureRecognizer {
//      //          longPressRecognizer.minimumPressDuration = 0
//      //        }
//      //      }
//      return self.view.collections[0].count
//    }
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//      return self.view.collections[0].count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//      switch self.view.contentSize {
//      case .fixed(let size):
//        return size
//      case .variable(let sizeForData):
//        let data = self.view.collections[indexPath.section][indexPath.item]
//        return sizeForData(data)
//      case .crossAxisFilled(let mainAxisLength):
//        switch self.view.scrollDirection {
//        case .horizontal:
//          return CGSize(width: mainAxisLength, height: collectionView.bounds.height)
//        case .vertical:
//          fallthrough
//        @unknown default:
//          return CGSize(width: collectionView.bounds.width, height: mainAxisLength)
//        }
//      case .custom(let customSizeForData):
//        let data = self.view.collections[indexPath.section][indexPath.item]
//        return customSizeForData(collectionView, collectionViewLayout, data)
//      }
//    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
      // this can be anything!
      return self.view.collection
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Data) -> ListSectionController {
      if object is String {
        return LabelSectionController()
      } else {
        return NumberSectionController()
      }
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
      return nil
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
      return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
      return collectionContext!.dequeueReusableCell(of: Data.self, for: self, at: index)
    }
    
//    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSection section: Int) -> EdgeInsets {
//      return self.view.sectionInset
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//      return self.view.itemSpacing.mainAxisSpacing
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//      return self.view.itemSpacing.crossAxisSpacing
//    }
  }
}

extension WinstonCollectionView {
  final class CollectionViewController : UIViewController {
    fileprivate let layout: UICollectionViewFlowLayout
    fileprivate let collectionView: UICollectionView
    
    init(scrollDirection: ScrollDirection, inset: EdgeInsets, coordinator: Coordinator) {
      //      let layout = UICollectionViewFlowLayout()
      //      self.contentForData = contentForData
      //      let layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
      //      let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
      //      layout.scrollDirection = scrollDirection
      //      self.layout = layout
      //
      //      super.init(collectionViewLayout: layout)
      ////      let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
      //      self.collectionView.showsVerticalScrollIndicator = false
      //      self.collectionView.backgroundColor = nil
      //      self.collectionView.isPrefetchingEnabled = true
      //      self.collectionView.dataSource = itemsDataSource
      //      //      collectionView.dataSource = coordinator.itemsDataSource
      //      self.collectionView.delegate = coordinator
      //      self.collectionView.contentInset = UIEdgeInsets(top: inset.top, left: inset.leading, bottom: inset.bottom, right: inset.trailing)
      ////      super.init(nibName: nil, bundle: nil)
      
      
      
      let layout = UICollectionViewFlowLayout()
      layout.scrollDirection = scrollDirection
      self.layout = layout
      
      let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
      collectionView.backgroundColor = nil
      collectionView.isPrefetchingEnabled = true
      collectionView.showsVerticalScrollIndicator = false
      collectionView.contentInset = UIEdgeInsets(top: inset.top, left: inset.leading, bottom: inset.bottom, right: inset.trailing)
      
      let updater = ListAdapterUpdater()
      let adapter = ListAdapter(updater: updater, viewController: coordinator)
      adapter.collectionView = collectionView
      adapter.dataSoure = coordinator
//      adapter.data
      
      self.collectionView = collectionView
      super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
      fatalError("In no way is this class related to an interface builder file.")
    }
    
    override func loadView() {
      self.view = self.collectionView
    }
  }
}
