import Foundation

enum FeedAction: Action {
    case updateFeed
    case addItem
    case removeItem(id: UUID)

<<<<<<<< HEAD:FirebaseUserStore/App/Feed/Store/Actions.swift
    case showAboutSheet(serviceData: SessionServiceSlice)
========
    case showAboutSheet
    case showAlert(error: Error)

    case logout

    case mockAction
>>>>>>>> redux:FirebaseUserStore/App/Feed/Store/FeedAction.swift
}
