import Combine
import Foundation

let registerationReducer: ReducerType<RegisterationState, RegisterationMutation, NoneTransition> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .progressStatus(status):
        state.progress.progressStatus = status
        
    case let .first(status):
        state.firstIsValid = status
        
    case let .second(status):
        state.secondIsValid = status

    case let .errorAlert(error):
        state.alert.error = error
        
    case .close:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

