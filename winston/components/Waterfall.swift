// SwiftUI `CollectionView` type implemented with UIKit's UICollectionView under the hood.
// Requires `UIViewControllerRepresentable` over `UIViewRepresentable` as the type that allows
// for SwiftUI `View`s to be added as subviews of UIKit `UIView`s at all bridges this gap as
// the `UIHostingController`.
//
// Not battle-tested yet, but seems to be working well so far.
// Expect changes.
import SwiftUI
import UIKit
import CHTCollectionViewWaterfallLayout

struct Waterfall<Collections, CellContent>: UIViewControllerRepresentable where
Collections : RandomAccessCollection,
Collections.Index == Int,
Collections.Element : RandomAccessCollection,
Collections.Element.Index == Int,
Collections.Element.Element : (Identifiable & Equatable),
CellContent : View {
  
  typealias Row = Collections.Element
  typealias Data = Row.Element
  typealias ContentForData = (Data, Int) -> CellContent
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
  
  fileprivate let collections: Collections
  fileprivate let contentForData: ContentForData
  fileprivate let scrollDirection: ScrollDirection
  fileprivate let contentSize: ContentSize
  fileprivate let itemSpacing: ItemSpacing
  fileprivate let rawCustomize: RawCustomize?
  fileprivate let theme: SubPostsListTheme
  
  init(
    collections: Collections,
    scrollDirection: ScrollDirection = .vertical,
    contentSize: ContentSize,
    itemSpacing: ItemSpacing = ItemSpacing(mainAxisSpacing: 0, crossAxisSpacing: 0),
    rawCustomize: RawCustomize? = nil,
    contentForData: @escaping ContentForData,
    theme: SubPostsListTheme
  ) {
    self.collections = collections
    self.scrollDirection = scrollDirection
    self.contentSize = contentSize
    self.itemSpacing = itemSpacing
    self.rawCustomize = rawCustomize
    self.contentForData = contentForData
    self.theme = theme
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(view: self)
  }
  
  func makeUIViewController(context: Context) -> ViewController {
    let coordinator = context.coordinator
    let viewController = ViewController(coordinator: coordinator, scrollDirection: self.scrollDirection, theme: self.theme)
    coordinator.viewController = viewController
    self.rawCustomize?(viewController.collectionView)
    return viewController
  }
  
  func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    // TODO: Obviously we can be efficient about what needs to be updated here
//    var indexes: [IndexPath] = []
//    
//    Array(self.collections[0].enumerated()).forEach { i, x in
//      if context.coordinator.view.collections.count == 1, context.coordinator.view.collections[0][safe: i] != x {
//        indexes.append(IndexPath(item: i, section: 0))
//      }
//    }
    context.coordinator.view = self
    //    uiViewController.layout.scrollDirection = self.scrollDirection
//    self.rawCustomize?(uiViewController.collectionView)
    uiViewController.collectionView.reloadData()
    
  }
}

extension Waterfall {
  
  /*
   Convenience init for a single-section CollectionView
   */
  init<Collection>(
    collection: Collection,
    scrollDirection: ScrollDirection = .vertical,
    contentSize: ContentSize,
    itemSpacing: ItemSpacing = ItemSpacing(mainAxisSpacing: 0, crossAxisSpacing: 0),
    rawCustomize: RawCustomize? = nil,
    contentForData: @escaping ContentForData,
    theme: SubPostsListTheme
  ) where Collections == [Collection]
  {
    self.init(
      collections: [collection],
      scrollDirection: scrollDirection,
      contentSize: contentSize,
      itemSpacing: itemSpacing,
      rawCustomize: rawCustomize,
      contentForData: contentForData,
      theme: theme
    )
  }
}

extension Waterfall {
  
  fileprivate static var cellReuseIdentifier: String {
    return "HostedCollectionViewCell"
  }
}

extension Waterfall {
  
  final class ViewController : UIViewController {
    
    fileprivate let collectionView: UICollectionView
    
    init(coordinator: Coordinator, scrollDirection: ScrollDirection, theme: SubPostsListTheme) {
      
      //      let layout = UICollectionViewFlowLayout()
      //      layout.scrollDirection = scrollDirection
      
      let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
      collectionView.backgroundColor = nil
      collectionView.register(HostedCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
      collectionView.dataSource = coordinator
      collectionView.delegate = coordinator
//      collectionView.contentInset = .zero
      collectionView.showsVerticalScrollIndicator = false
      self.collectionView = collectionView
      
      let layout = CHTCollectionViewWaterfallLayout()
      
      // Change individual layout attributes for the spacing between cells
      layout.minimumColumnSpacing = theme.spacing
      layout.minimumInteritemSpacing = theme.spacing
////      layout.minimumColumnSpacing = 0
////      layout.minimumInteritemSpacing = 0
      layout.sectionInset = .init(top: 0, left: theme.theme.outerHPadding, bottom: 0, right: theme.theme.outerHPadding)
////      layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
//      layout.sectionInsetReference = .fromLayoutMargins
//      layout.itemRenderDirection = .shortestFirst
//      layout.headerHeight = 0
//      layout.footerHeight = 0
      
      collectionView.collectionViewLayout = layout
      
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

extension Waterfall {
  
  final class Coordinator : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    fileprivate var view: Waterfall
    fileprivate var viewController: ViewController?
    
    init(view: Waterfall) {
      self.view = view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      return self.view.collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.view.collections[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! HostedCollectionViewCell
      let data = self.view.collections[indexPath.section][indexPath.item]
      let content = self.view.contentForData(data, indexPath.item)
      cell.provide(content)
      return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      let cell = cell as! HostedCollectionViewCell
      cell.attach(to: self.viewController!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      let cell = cell as! HostedCollectionViewCell
      cell.detach()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      switch self.view.contentSize {
      case .fixed(let size):
        return size
      case .variable(let sizeForData):
        let data = self.view.collections[indexPath.section][indexPath.item]
        return sizeForData(data)
      case .crossAxisFilled(let mainAxisLength):
        switch self.view.scrollDirection {
        case .horizontal:
          return CGSize(width: mainAxisLength, height: collectionView.bounds.height)
        case .vertical:
          fallthrough
        @unknown default:
          return CGSize(width: collectionView.bounds.width, height: mainAxisLength)
        }
      case .custom(let customSizeForData):
        let data = self.view.collections[indexPath.section][indexPath.item]
        return customSizeForData(collectionView, collectionViewLayout, data)
      }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//      return self.view.itemSpacing.mainAxisSpacing
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingFor section: Int) -> CGFloat {
//      return self.view.itemSpacing.crossAxisSpacing
//    }
  }
}

private extension Waterfall {
  
  final class HostedCollectionViewCell : UICollectionViewCell {
    
    var viewController: UIHostingController<CellContent>?
    
    func provide(_ content: CellContent) {
      if let viewController = self.viewController {
        viewController.rootView = content
      } else {
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = nil
        self.viewController = hostingController
      }
    }
    
    func attach(to parentController: UIViewController) {
      let hostedController = self.viewController!
      let hostedView = hostedController.view!
      let contentView = self.contentView
      
      parentController.addChild(hostedController)
      
      hostedView.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(hostedView)
      hostedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
      hostedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
      hostedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
      hostedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
      
      hostedController.didMove(toParent: parentController)
    }
    
    func detach() {
      let hostedController = self.viewController!
      guard hostedController.parent != nil else { return }
      let hostedView = hostedController.view!
      
      hostedController.willMove(toParent: nil)
      hostedView.removeFromSuperview()
      hostedController.removeFromParent()
    }
  }
}

extension Collection where Indices.Iterator.Element == Index {
   public subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}
