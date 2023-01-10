import Foundation
import Combine

enum RegisterationMutation: Mutation {
    case progressStatus(_ status: ProgressViewStatus)

    case first(status: Bool)
    case second(status: Bool)

    case errorAlert(error: Error)

    case close
}

