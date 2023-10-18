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
import UIKit
import Defaults

struct CollectionView
<Collections, CellContent>
: UIViewControllerRepresentable
where
Collections : RandomAccessCollection,
Collections.Index == Int,
Collections.Element : RandomAccessCollection & Hashable,
Collections.Element.Index == Int,
Collections.Element.Element : Identifiable,
CellContent : View
{
  
  typealias Row = Collections.Element
  typealias Data = Row.Element
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
  
  fileprivate let collections: Collections
  fileprivate let contentForData: ContentForData
  fileprivate let scrollDirection: ScrollDirection
  fileprivate let contentSize: ContentSize
  fileprivate let itemSpacing: ItemSpacing
  fileprivate let sectionInset: EdgeInsets
  fileprivate let rawCustomize: RawCustomize?
  
  init(
    collections: Collections,
    scrollDirection: ScrollDirection = .vertical,
    contentSize: ContentSize,
    itemSpacing: ItemSpacing = ItemSpacing(mainAxisSpacing: 0, crossAxisSpacing: 0),
    sectionInset: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
    rawCustomize: RawCustomize? = nil,
    contentForData: @escaping ContentForData)
  {
    self.collections = collections
    self.scrollDirection = scrollDirection
    self.contentSize = contentSize
    self.itemSpacing = itemSpacing
    self.sectionInset = sectionInset
    self.rawCustomize = rawCustomize
    self.contentForData = contentForData
  }
  
  private func createHostingConfiguration(controller: UIViewController, for item: Data, indexPath: IndexPath, total: Int) -> UIHostingConfiguration<CellContent, EmptyView> {
    let cell = UIHostingConfiguration(content: { contentForData(item, controller, indexPath.item, total) })
    //    ce
    return cell
  }
  
  func makeCoordinator() -> Coordinator {
    //    let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Data> { cell, indexPath, item in
    //      cell.contentConfiguration = createHostingConfiguration(controller: uiViewController, for: item, indexPath: indexPath, total: self.collections[0].count)
    //    }
    return Coordinator(view: self)
  }
  
  func makeUIViewController(context: Context) -> ViewController {
    let coordinator = context.coordinator
    let viewController = ViewController(coordinator: coordinator, scrollDirection: self.scrollDirection, inset: self.sectionInset)
    coordinator.viewController = viewController
    let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Data> { cell, indexPath, item in
      cell.contentConfiguration = createHostingConfiguration(controller: viewController, for: item, indexPath: indexPath, total: self.collections[0].count)
    }
    coordinator.registration = registration
    self.rawCustomize?(viewController.collectionView)
    return viewController
  }
  
  func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    // TODO: Obviously we can be efficient about what needs to be updated here
    context.coordinator.view = self
    //    uiViewController.layout.scrollDirection = self.scrollDirection
    //    self.rawCustomize?(uiViewController.collectionView)
    if context.coordinator.oldCollectionsCount != collections[0].count {
//      let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Data> { cell, indexPath, item in
//        cell.contentConfiguration = createHostingConfiguration(controller: uiViewController, for: item, indexPath: indexPath, total: self.collections[0].count)
//      }
//      context.coordinator.registration = registration
      context.coordinator.oldCollectionsCount = collections[0].count
      uiViewController.collectionView.reloadData()
    }
  }
}

extension CollectionView {
  
  /*
   Convenience init for a single-section CollectionView
   */
  init<Collection>(
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
}

extension CollectionView {
  final class ViewController : UIViewController {
    fileprivate let layout: UICollectionViewFlowLayout
    fileprivate let collectionView: UICollectionView
    
    init(coordinator: Coordinator, scrollDirection: ScrollDirection, inset: EdgeInsets) {
      let layout = UICollectionViewFlowLayout()
      //      self.contentForData = contentForData
      //      let layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
      //      let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
      //      layout.scrollDirection = scrollDirection
      self.layout = layout
      
      let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
      collectionView.showsVerticalScrollIndicator = false
      collectionView.backgroundColor = nil
      collectionView.isPrefetchingEnabled = true
      collectionView.dataSource = coordinator
      collectionView.delegate = coordinator
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

extension CollectionView {
  
  final class Coordinator : NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate var view: CollectionView
    fileprivate var viewController: ViewController?
    fileprivate var oldCollectionsCount: Int = 0
    
    var registration: UICollectionView.CellRegistration<UICollectionViewListCell, Data>!
    
    init(view: CollectionView) {
      self.view = view
      //      registration = .init(cellNib: nil, handler: { cell, indexPath, itemIdentifier in
      //
      //      })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      //      collectionView.gestureRecognizers?.forEach { (recognizer) in
      //        if let longPressRecognizer = recognizer as? UILongPressGestureRecognizer {
      //          longPressRecognizer.minimumPressDuration = 0
      //        }
      //      }
      return self.view.collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.view.collections[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let item = self.view.collections[indexPath.section][indexPath.item]
//      UIHostingConfiguration(content: { contentForData(item, controller, indexPath.item, total) })
//      collectionView.dequeueReusableCell(withReuseIdentifier: item.id, for: <#T##IndexPath#>)
      return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
      //      return collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
    }
    
    //    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //      let cell = cell as! HostedCollectionViewCell
    //      cell.attach(to: self.viewController!)
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //      let cell = cell as! HostedCollectionViewCell
    //      cell.detach()
    //    }
    
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
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSection section: Int) -> EdgeInsets {
      return self.view.sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return self.view.itemSpacing.mainAxisSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return self.view.itemSpacing.crossAxisSpacing
    }
  }
}

private extension CollectionView {
  
  //  final class HostedCollectionViewCell : UICollectionViewCell {
  //
  //    var viewController: UIHostingController<CellContent>?
  //
  //    func provide(_ content: CellContent) {
  //      if let viewController = self.viewController {
  //        viewController.rootView = content
  //      } else {
  //        let hostingController = UIHostingController(rootView: content)
  //        hostingController.view.backgroundColor = nil
  //        self.viewController = hostingController
  //      }
  //    }
  //
  //    func attach(to parentController: UIViewController) {
  //      let hostedController = self.viewController!
  //      let hostedView = hostedController.view!
  //      let contentView = self.contentView
  //
  //      parentController.addChild(hostedController)
  //
  //      hostedView.translatesAutoresizingMaskIntoConstraints = false
  //      contentView.addSubview(hostedView)
  //      hostedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
  //      hostedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
  //      hostedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
  //      hostedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
  //
  //      hostedController.didMove(toParent: parentController)
  //    }
  //
  //    func detach() {
  //      let hostedController = self.viewController!
  //      guard hostedController.parent != nil else { return }
  //      let hostedView = hostedController.view!
  //
  //      hostedController.willMove(toParent: nil)
  //      hostedView.removeFromSuperview()
  //      hostedController.removeFromParent()
  //    }
  //  }
}

