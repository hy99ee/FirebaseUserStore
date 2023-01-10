import SwiftUI

struct FeedCollectionView: View {
    let store: FeedStore
    @Binding var searchQuery: String

    @State private var isAnimating = false

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    private let progress = HDotsProgress()

    var body: some View {
        NavigationView {
            if store.state.itemsPreloadersCount == 0 {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<store.state.items.count, id: \.self) { index in
                            FeedCellView(title: store.state.items[index].title) {
                                store.dispatch(.removeItem(id: store.state.items[index].id))
                            }
                            .onTapGesture {
                                store.dispatch(.click(store.state.items[index]))
                            }
                            .padding(3)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.easeIn(duration: 0.7).delay(Double(index) * 0.03), value: isAnimating)
                        }
                    }
                }
                .modifier(AnimationProgressViewModifier(provider: store.state.viewProgress, animation: .easeIn(duration: 0.5).repeatForever()))
                .refreshable {
                    await asyncUpdate()
                }
                .onAppear {
                    isAnimating = true
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.state.loadItems, id: \.id) { _ in
                            LoaderFeedCellView()
                                .padding(3)
                        }
                    }
                }
                .modifier(StaticPreloaderViewModifier())
                .onAppear { isAnimating = false }
            }
        }
        .padding(12)
        .cornerRadius(22)
    }

    func asyncUpdate() async -> Void {
        searchQuery.isEmpty ? store.dispatch(.updateFeed) : store.dispatch(.search(text: searchQuery))

        try? await self.store.objectWillChange
            .filter { self.store.state.viewProgress.progressStatus == .stop }
            .eraseToAnyPublisher()
            .async()
    }
}
