import SwiftUI
import Combine


struct FeedView: View {
    @StateObject var store: FeedStore

    private let searchQueryBublisher = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()

    @State private var showLoader = false
    @State private var isRefresh = false
    @State private var errorFeedDelay = false

    init(store: FeedStore) {
        self._store = StateObject(wrappedValue: store)

        searchQueryBublisher
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { $0.isEmpty ? store.dispatch(.updateFeed) : store.dispatch(.search(text: $0)) }
            .store(in: &subscriptions)
    }

    var body: some View {
        mainView
    }

    var mainView: some View {
        VStack {
            if store.state.showEmptyView {
                emptyView()
            } else if store.state.showErrorView {
                updateableErrorView()
            } else {
                let searchBinding = Binding<String>(
                    get: { searchQueryBublisher.value },
                    set: { searchQueryBublisher.send($0) }
                  )
                SearchBar(searchQuery: searchBinding)
                FeedCollectionView(store: store, searchQuery: searchBinding)
            }
        }
        .toolbar { toolbarView() }
        .modifier(AlertShowViewModifier(provider: store.state.alert))
    }

    private func updateableErrorView() -> some View {
        VStack {
            Spacer()
            Text("Error").monospacedDigit().bold().foregroundColor(.red)
            ImageView(systemName: "arrow.triangle.2.circlepath") {
                withAnimation {
                    errorFeedDelay = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        errorFeedDelay = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            store.dispatch(.updateFeed)
                        }
                    }
                }
            }
            .modifier(ButtonProgressViewModifier(provider: store.state.viewProgress, type: .clearView))
            .disabled(errorFeedDelay)
            .padding()
            
            Spacer()
        }
    }

    private func emptyView() -> some View {
        return VStack {
            Spacer()
            Text("Empty").bold()
            Spacer()
        }
    }

    private func toolbarView() -> some View {
        return HStack {
            ImageView(systemName: "person", size: 18) {
                store.dispatch(.showAboutSheet)
            }
            .padding([.leading, .trailing], 8)
            ImageView(systemName: "plus", size: 20) {
                store.dispatch(.addItem)
            }
            .modifier(ProcessViewModifier(provider: store.state.processView))
            .modifier(ButtonProgressViewModifier(provider: store.state.buttonProgress, type: .clearView))
        }
    }
}

extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}
