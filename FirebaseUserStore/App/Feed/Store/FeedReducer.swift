import Combine
import SwiftUI

let feedReducer: ReducerType<FeedState, FeedMutation, FeedLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .fetchItemsPreloaders(count):
        state.showEmptyView = count == 0
        state.itemsPreloadersCount = count
        state.items = []

    case let .fetchItems(items):
        let items = items.sorted(by: FeedState.sortingByModified)
        state.showEmptyView = items.isEmpty
        state.itemsPreloadersCount = 0
        state.items = items

    case .clean:
        state.itemsPreloadersCount = 0
        state.items = []

    case .empty:
        emptyData()
    
    case let .detail(item):
        return Just(.coordinate(destination: .detail(item))).eraseToAnyPublisher()

    case let .addItems(items):
        state.items.append(contentsOf: items)

    case let .newItem(item):
        state.items.append(item)
        state.showEmptyView = false

    case let .removeItem(id):
        state.items.removeAll { $0.id == id }
        if state.items.isEmpty { state.showEmptyView = true }

    case let .errorAlert(error):
        state.alert.error = error

    case .errorFeed:
        errorData()

    case let .showAbout(data):
        return Just(.coordinate(destination: .about(data))).eraseToAnyPublisher()

    case let .progressViewStatus(status):
        state.viewProgress.progressStatus = status

    case let .progressButtonStatus(status):
        state.buttonProgress.progressStatus = status

    case .logout:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
    
    func emptyData() {
        state.itemsPreloadersCount = 0
        state.items = []
        state.showEmptyView = true
    }

    func errorData() {
        state.itemsPreloadersCount = 0
        state.items = []
        state.showErrorView = true
    }
}
