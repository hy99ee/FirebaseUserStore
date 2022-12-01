import Foundation
import Combine

protocol MiddlewareStoreType {
    associatedtype StoreState: StateType
    associatedtype StoreAction: Action
    associatedtype StorePackages: EnvironmentPackages
    associatedtype MiddlewareRedispatch: Error

    associatedtype Middleware = (StoreState, StoreAction) -> AnyPublisher<StoreAction, MiddlewareRedispatch>

    func dispatch(state: StoreState, action: StoreAction, packages: StorePackages, isRedispatch: Bool) -> AnyPublisher<StoreAction, MiddlewareRedispatch>
}

typealias _MiddlewareStore = MiddlewareStore
final class MiddlewareStore<StoreState, StoreAction, StorePackages>: MiddlewareStoreType where StoreState: StateType,
                                                                                            StoreAction: Action,
                                                                                            StorePackages: EnvironmentPackages {
    typealias Middleware = (StoreState, StoreAction, StorePackages) -> AnyPublisher<StoreAction, MiddlewareRedispatch>

    enum RedispatchType {
        case repeatRedispatch
        case excludeRedispatch
        case stopFlow
    }
    enum MiddlewareRedispatch: Error {
        case redispatch(action: StoreAction, type: RedispatchType)
        case stopFlow
    }

    private let middlewares: [Middleware]
    private var processMiddlewares: [Middleware]
    private var anyCancellables: Set<AnyCancellable> = []
    private var index = 0

    init(middlewares: [Middleware]) {
        self.middlewares = middlewares
        self.processMiddlewares = self.middlewares
    }

    func dispatch(state: StoreState, action: StoreAction, packages: StorePackages, isRedispatch: Bool) -> AnyPublisher<StoreAction, MiddlewareRedispatch>  {
        Deferred {
            Future {[unowned self] promise in
                self.anyCancellables = []
                self.index = 0
                (isRedispatch ? processMiddlewares : middlewares).publisher
                    .flatMap { $0(state, action, packages) }
                    .handleEvents(receiveOutput: { [weak self] _ in self?.index += 1 })
                    .sink(receiveCompletion: {[unowned self] in
                        switch $0 {
                        case .finished:
                            print("Successful finish middlewares flow with action: \(action)")
                            processMiddlewares = middlewares
                            promise(.success(action))
                        case .failure(.stopFlow):
                            print("Stop middlewares flow")
                            promise(.failure(.stopFlow))
                        case let .failure(.redispatch(action, type)):
                            print("Redispatch from middlewares flow with action: \(action)")
                            switch type {
                            case .excludeRedispatch:
                                self.processMiddlewares.remove(at: self.index)
                            default: break
                            }
                            promise(.failure(.redispatch(action: action, type: type)))
                        }
                    }, receiveValue: { _ in })
                    .store(in: &anyCancellables)
            }
        }.eraseToAnyPublisher()
    }
}
