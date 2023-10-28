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
import SectionKit
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
    @ViewBuilder contentForData: @escaping ContentForData)
  {
    self.collection = collection
    self.scrollDirection = scrollDirection
    self.contentSize = contentSize
    self.itemSpacing = itemSpacing
    self.sectionInset = sectionInset
    self.rawCustomize = rawCustomize
    self.contentForData = contentForData
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
    viewController.collectionViewAdapter = ListCollectionViewAdapter(
      collectionView: viewController.collectionView,
      dataSource: context.coordinator, // no worries, we're going to add conformance to the protocol in a bit
      viewController: viewController
    )
//    collectionView.register(
//      CharacterCollectionViewCell.self,
//      forCellWithReuseIdentifier: CharacterCollectionViewCell.description()
//    )
    return viewController
  }
  
  func updateUIViewController(_ viewController: CollectionViewController, context: Context) {
    context.coordinator.view = self
//    context.coordinator.
    viewController.collectionViewAdapter.invalidateDataSource()
    //    uiViewController.collectionView.
  }
}

extension WinstonCollectionView {
  
  final class Coordinator : NSObject, ListCollectionViewAdapterDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    fileprivate var view: WinstonCollectionView
    fileprivate var collectionController: CollectionViewController?
    
    init(view: WinstonCollectionView) {
      self.view = view
    }
    
    private func createSectionModels() -> [FeedFirstSectionModel<T, B>] {
      [FeedFirstSectionModel(items: view.collection)]
    }
    
    func sections(for adapter: SectionKit.CollectionViewAdapter) -> [SectionKit.Section] {
      createSectionModels().compactMap { model in
        if let collectionController = self.collectionController {
          let controler = DataSectionController(model: model, contentForData: self.view.contentForData, collectionController: collectionController)
          return Section(
            id: model.sectionId,
            model: model,
            controller: controler
          )
        }
        return nil
      }
    }
    
    class DataSectionController: FoundationDiffingListSectionController<FeedFirstSectionModel<T, B>, Data> {
      fileprivate var contentForData: ContentForData
      fileprivate var collectionController: CollectionViewController
      
      init(model: FeedFirstSectionModel<T, B>, contentForData: @escaping ContentForData, collectionController: CollectionViewController) {
        self.contentForData = contentForData
        self.collectionController = collectionController
        super.init(model: model)
      }
      
      override func items(for model: FeedFirstSectionModel<T, B>) -> [Data] {
        return model.items
      }
      
      override func cellForItem(at indexPath: SectionIndexPath, in context: CollectionViewContext) -> UICollectionViewCell {
        let cell = context.dequeueReusableCell(CharacterCollectionViewCell.self, for: indexPath)
        let item = items[indexPath]
        
//        if cell.contentConfiguration == nil {
          let contentConfiguration = UIHostingConfiguration { contentForData(item, collectionController, indexPath.indexInSectionController, items.count) }
          cell.contentConfiguration = contentConfiguration
//        }
        return cell
      }
      
      override func sizeForItem(at indexPath: SectionIndexPath, using layout: UICollectionViewLayout, in context: CollectionViewContext) -> CGSize {
        if let post = items[indexPath] as? Post, let winstonData = post.winstonData {
          return winstonData.postDimensions.size
        }
        return CGSize(width: context.containerSize.width, height: 300)
      }
    }
  }
}
struct FeedFirstSectionModel<T: GenericRedditEntityDataType, B: Hashable> {
  let items: [GenericRedditEntity<T, B>]
}

enum FeedSectionId: Hashable {
  case first
}

protocol FeedSection {
  var sectionId: FeedSectionId { get }
}

extension FeedFirstSectionModel: FeedSection {
  var sectionId: FeedSectionId { .first }
}

extension WinstonCollectionView {
  final class CollectionViewController : UIViewController {
    fileprivate let layout: UICollectionViewFlowLayout
    fileprivate let collectionView: UICollectionView
    fileprivate var collectionViewAdapter: CollectionViewAdapter!
    
    
    init(scrollDirection: ScrollDirection, inset: EdgeInsets, coordinator: Coordinator) {
      let layout = UICollectionViewFlowLayout()
      layout.scrollDirection = scrollDirection
      self.layout = layout
      
      let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
      collectionView.backgroundColor = nil
      collectionView.isPrefetchingEnabled = true
      collectionView.showsVerticalScrollIndicator = false
      collectionView.contentInset = UIEdgeInsets(top: inset.top, left: inset.leading, bottom: inset.bottom, right: inset.trailing)
      
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

final class CharacterCollectionViewCell: UICollectionViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        contentConfiguration = nil
    }

}
