import SwiftUI
import Combine

struct FeedState: StateType {
    var itemsPreloadersCount = 0 {
        didSet {
            loadItems = Array(repeating: LoaderItem(), count: itemsPreloadersCount)
        }
    }

    var loadItems: [LoaderItem] = []
    var items: [Item] = [] {
        didSet {
            showErrorView = false
        }
    }

    var showEmptyView = false
    var showErrorView = false

    var alert = AlertProvider()
//    var aboutSheetProvider = AboutSheetProvider()

    var viewProgress = ProgressViewProvider()
    var buttonProgress = ProgressViewProvider()

    let processView: ProcessViewProvider

    init() {
        processView = ProcessViewProvider(viewProgress, buttonProgress)
    }
}

extension FeedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt < $1.modifiedAt
    }

    func itemsWithFilter(_ filter: String) -> [Item] {
        items.filter { $0.title.lowercased().contains(filter.lowercased()) }
    }
}
