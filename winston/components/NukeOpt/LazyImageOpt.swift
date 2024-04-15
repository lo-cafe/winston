//
//  LazyImageOpt.swift
//  winston
//
//  Created by Igor Marcossi on 14/04/24.
//

import Foundation
import Nuke
import NukeUI
import SwiftUI
import Combine


/// A view that asynchronously loads and displays an image.
///
/// ``LazyImage`` is designed to be similar to the native [`AsyncImage`](https://developer.apple.com/documentation/SwiftUI/AsyncImage),
/// but it uses [Nuke](https://github.com/kean/Nuke) for loading images. You
/// can take advantage of all of its features, such as caching, prefetching,
/// task coalescing, smart background decompression, request priorities, and more.
@MainActor
@available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 10.16, *)
public struct LazyImageOpt<Content: View>: View {
    @State private var viewModel = FetchImageOpt()

    private var context: LazyImageContextOpt?
    private var makeContent: ((LazyImageStateOpt) -> Content)?
    private var transaction: Transaction
    private var pipeline: ImagePipeline = .shared
    private var onStart: ((ImageTask) -> Void)?
    private var onDisappearBehavior: DisappearBehavior? = .cancel
    private var onCompletion: ((Result<ImageResponse, Error>) -> Void)?

    // MARK: Initializers

    /// Loads and displays an image using `SwiftUI.Image`.
    ///
    /// - Parameters:
    ///   - url: The image URL.
    public init(url: URL?) where Content == Image {
        self.init(request: url.map { ImageRequest(url: $0) })
    }

    /// Loads and displays an image using `SwiftUI.Image`.
    ///
    /// - Parameters:
    ///   - request: The image request.
    public init(request: ImageRequest?) where Content == Image {
        self.context = request.map(LazyImageContextOpt.init)
        self.transaction = Transaction(animation: nil)
    }

    /// Loads an images and displays custom content for each state.
    ///
    /// See also ``init(request:transaction:content:)``
    public init(url: URL?,
                transaction: Transaction = Transaction(animation: nil),
                @ViewBuilder content: @escaping (LazyImageStateOpt) -> Content) {
        self.init(request: url.map { ImageRequest(url: $0) }, transaction: transaction, content: content)
    }

    /// Loads an images and displays custom content for each state.
    ///
    /// - Parameters:
    ///   - request: The image request.
    ///   - content: The view to show for each of the image loading states.
    ///
    /// ```swift
    /// LazyImage(request: $0) { state in
    ///     if let image = state.image {
    ///         image // Displays the loaded image.
    ///     } else if state.error != nil {
    ///         Color.red // Indicates an error.
    ///     } else {
    ///         Color.blue // Acts as a placeholder.
    ///     }
    /// }
    /// ```
    public init(request: ImageRequest?,
                transaction: Transaction = Transaction(animation: nil),
                @ViewBuilder content: @escaping (LazyImageStateOpt) -> Content) {
        self.context = request.map { LazyImageContextOpt(request: $0) }
        self.transaction = transaction
        self.makeContent = content
    }

    // MARK: Options

    /// Sets processors to be applied to the image.
    ///
    /// If you pass an image requests with a non-empty list of processors as
    /// a source, your processors will be applied instead.
    public func processors(_ processors: [any ImageProcessing]?) -> Self {
        map { $0.context?.request.processors = processors ?? [] }
    }

    /// Sets the priority of the requests.
    public func priority(_ priority: ImageRequest.Priority?) -> Self {
        map { $0.context?.request.priority = priority ?? .normal }
    }

    /// Changes the underlying pipeline used for image loading.
    public func pipeline(_ pipeline: ImagePipeline) -> Self {
        map { $0.pipeline = pipeline }
    }

    public enum DisappearBehavior {
        /// Cancels the current request but keeps the presentation state of
        /// the already displayed image.
        case cancel
        /// Lowers the request's priority to very low
        case lowerPriority
    }

    /// Gets called when the request is started.
    public func onStart(_ closure: @escaping (ImageTask) -> Void) -> Self {
        map { $0.viewModel.onStart = closure }
    }

    /// Override the behavior on disappear. By default, the view is reset.
    public func onDisappear(_ behavior: DisappearBehavior?) -> Self {
        map { $0.onDisappearBehavior = behavior }
    }

    /// Gets called when the current request is completed.
    public func onCompletion(_ closure: @escaping (Result<ImageResponse, Error>) -> Void) -> Self {
        map { $0.onCompletion = closure }
    }

    private func map(_ closure: (inout LazyImageOpt) -> Void) -> Self {
        var copy = self
        closure(&copy)
        return copy
    }

    // MARK: Body

    public var body: some View {
        ZStack {
            if let makeContent {
                makeContent(viewModel)
            } else {
                makeDefaultContent(for: viewModel)
            }
        }
        .onAppear { onAppear() }
        .onDisappear { onDisappear() }
        .onChange(of: context) {
            viewModel.load($1?.request)
        }
    }

    @ViewBuilder
    private func makeDefaultContent(for state: LazyImageStateOpt) -> some View {
        if let image = state.image {
            image
        } else {
            Color(.secondarySystemBackground)
        }
    }

    private func onAppear() {
        viewModel.transaction = transaction
        viewModel.pipeline = pipeline
        viewModel.onStart = onStart
        viewModel.onCompletion = onCompletion
        viewModel.load(context?.request)
    }

    private func onDisappear() {
        guard let behavior = onDisappearBehavior else { return }
        switch behavior {
        case .cancel:
            viewModel.cancel()
        case .lowerPriority:
            viewModel.priority = .veryLow
        }
    }
}

private struct LazyImageContextOpt: Equatable {
    var request: ImageRequest

    static func == (lhs: LazyImageContextOpt, rhs: LazyImageContextOpt) -> Bool {
        let lhs = lhs.request
        let rhs = rhs.request
        return lhs.preferredImageIdCopy == rhs.preferredImageIdCopy &&
        lhs.priority == rhs.priority &&
        lhs.description == rhs.description &&
        lhs.priority == rhs.priority &&
        lhs.options == rhs.options
    }
}

extension ImageRequest {
    var preferredImageIdCopy: String {
        if !userInfo.isEmpty, let imageId = userInfo[.imageIdKey] as? String {
            return imageId
        }
        return imageId ?? ""
    }
}
