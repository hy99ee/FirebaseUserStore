import Combine
import Foundation

let forgotReducer: ReducerType<ForgotState, ForgotMutation, NoneTransition> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .progressForgotStatus(status):
        state.progress.progressStatus = status
    
    case let .emailValid(status):
        state.isValidEmailField = status

    case let .errorAlert(error):
        state.alert.error = error

    case .close:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

