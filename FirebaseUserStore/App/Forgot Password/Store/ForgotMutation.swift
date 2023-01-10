import Foundation
import Combine

enum ForgotMutation: Mutation {
    case progressForgotStatus(_ status: ProgressViewStatus)
    case emailValid(status: Bool)
    case errorAlert(error: Error)
    case close
}

