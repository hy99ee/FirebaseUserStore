import Foundation
import Combine

enum FeedMutation: Mutation {
    case fetchItemsPreloaders(count: Int)
    case fetchItems(newItems: [Item])
    case clean

    case detail(item: Item)

    case newItem(item: Item)
    case addItems(items: [Item])
    case removeItem(id: UUID)
    case empty

    case logout

    case errorAlert(error: Error)
    case errorFeed

    case showAbout(data: AboutViewData)
    case progressButtonStatus(status: ProgressViewStatus)
    case progressViewStatus(status: ProgressViewStatus)
}
