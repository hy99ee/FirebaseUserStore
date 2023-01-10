import Combine
import SwiftUI
import Firebase

let feedDispatcher: DispatcherType<FeedAction, FeedMutation, FeedPackages> = { action, packages in
    switch action {
    case .updateFeed:
        return mutationFetchItems(packages: packages)

    case let .click(item):
        return Just(FeedMutation.detail(item: item)).eraseToAnyPublisher()

    case .addItem:
        return mutationAddItem(packages: packages).withStatus(start: FeedMutation.progressButtonStatus(status: .start), finish: FeedMutation.progressButtonStatus(status: .stop))

    case let .addItems(items):
        return Just(FeedMutation.addItems(items: items)).eraseToAnyPublisher()

    case let .removeItem(id):
        return mutationRemoveItem(by: id, packages: packages)

    case let .search(text, local):
        return mutationSearchItems(by: text, local: local, packages: packages)

    case .clean:
        return Just(FeedMutation.clean).eraseToAnyPublisher()

    case .showAboutSheet:
        return mutationShowAboutSheet(packages: packages)

    case let .showAlert(error):
        return mutationShowAlert(with: error)
    
    case .showFeedError:
        return Just(FeedMutation.errorFeed).eraseToAnyPublisher()

    case .logout:
        return mutationLogout(packages: packages)

    case .mockAction:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationFetchItems(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        let fetchDocs = packages.itemsService.fetchQuery().share()

        let fetchFromDocs = fetchDocs
            .map { $0.query }
            .flatMap { packages.itemsService.fetchItems($0) }
        
        return Publishers.Merge(
            fetchDocs
                .map { docs in
                    if docs.count > 0 {
                        return FeedMutation.fetchItemsPreloaders(count: docs.count)
                    } else {
                        return FeedMutation.empty
                    }
                }
                .catch { Just(FeedMutation.errorAlert(error: $0)) }
                .eraseToAnyPublisher()
                .withStatus(start: FeedMutation.progressViewStatus(status: .start), finish: FeedMutation.progressViewStatus(status: .stop))
            , fetchFromDocs
                .map { FeedMutation.fetchItems(newItems: $0) }
                .catch { Just(FeedMutation.errorAlert(error: $0)) })
        .eraseToAnyPublisher()
        
    }
    func mutationAddItem(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        packages.itemsService.setNewItemRequest()
            .flatMap { packages.itemsService.fetchItem($0).eraseToAnyPublisher() }
            .map { FeedMutation.newItem(item: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationRemoveItem(by id: UUID, packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        packages.itemsService.removeItemRequest(id)
            .map { FeedMutation.removeItem(id: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationSearchItems(by text: String, local: Set<UUID>, packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        let fetchDocs = packages.itemsService.searchQuery(text)

        let fetchFromDocs = fetchDocs
            .flatMap {
                packages.itemsService.fetchItems($0.query) {
                    $0.title.lowercased().contains(text.lowercased()) && !local.contains($0.id)
                }
            }

        return fetchFromDocs
            .map { FeedMutation.addItems(items: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationShowAboutSheet(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        guard let user = packages.sessionService.userDetails else { return Just(FeedMutation.errorAlert(error: SessionServiceError.undefinedUserDetails)).eraseToAnyPublisher() }
        return Just(FeedMutation.showAbout(data: AboutViewData(user: user, logout: packages.sessionService.logout)))
            .eraseToAnyPublisher()
    }
    func mutationShowAlert(with error: Error) -> AnyPublisher<FeedMutation, Never> {
        Just(FeedMutation.errorAlert(error: error))
            .eraseToAnyPublisher()
    }
    func mutationLogout(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        Just(())
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { packages.sessionService.logout() })
            .map { FeedMutation.logout }
            .eraseToAnyPublisher()
    }
}
