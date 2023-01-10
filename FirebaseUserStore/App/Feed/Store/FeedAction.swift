import Foundation

enum FeedAction: Action {
    case updateFeed

    case click(_ item: Item)

    case addItems(items: [Item])
    case addItem
    case removeItem(id: UUID)
    case search(text: String, local: Set<UUID> = Set())
    case clean

    case showAboutSheet
    case showAlert(error: Error)
    case showFeedError

    case logout

    case mockAction
}
