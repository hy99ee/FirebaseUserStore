import Combine
import SwiftUI

protocol Action {}

protocol Mutation {}

enum EquivocalMutation<State, Transition> where State: StateType, Transition: TransitionType {
    case state(_ state: State)
    case coordinate(destination: Transition)
}

protocol StateType {
    var processView: ProcessViewProvider { get }
}

extension StateType {
    var processView: ProcessViewProvider { .shared }
}

protocol TransitionType: Hashable, Identifiable {}
enum NoneTransition : TransitionType {
    case none

    var id: String { String(describing: self) }
}

protocol TransitionSender {
    associatedtype SenderTransitionType: TransitionType

    var transition: PassthroughSubject<SenderTransitionType, Never> { get }
}

typealias DispatcherType<ActionType: Action, MutationType: Mutation, EnvironmentPackagesType: EnvironmentPackages> = ( _ action: ActionType, _ packages: EnvironmentPackagesType) -> AnyPublisher<MutationType, Never>

typealias ReducerType<StoreState: StateType, StoreMutation: Mutation, Transition: TransitionType> = (_ state: StoreState, _ mutation: StoreMutation) -> AnyPublisher<EquivocalMutation<StoreState, Transition>, Never>

protocol EnvironmentType {
    associatedtype ServiceError: Error
}

protocol EnvironmentPackages {}


