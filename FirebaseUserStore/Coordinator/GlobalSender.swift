import Combine
import SwiftUI

class GlobalSender: TransitionSender {
    @ObservedObject var sessionService = SessionService.shared
    private var subscriptions = Set<AnyCancellable>()
    private lazy var isFirstOpenKey = "isFirstOpen"
    private lazy var isFirstOpen = UserDefaults.standard.bool(forKey: isFirstOpenKey)

    let transition = PassthroughSubject<GlobalLink, Never>()
    
    init() {
        sessionService.$state
            .map {
                switch $0 {
                case .loggedIn:
                    return GlobalLink.login
                case .loggedOut:
                    return GlobalLink.logout
                case .loading:
                    return GlobalLink.progress
                }
            }
            .flatMap {[weak self] state -> AnyPublisher<GlobalLink, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }

                let sessionState = Just(state).share().eraseToAnyPublisher()
                if case .login = state, self.isFirstOpen {
                    return Publishers.Merge(
                        sessionState,
                        Just(GlobalLink.promo)
                            .handleEvents(receiveOutput: { _ in
                                self.isFirstOpen = false
                                UserDefaults.standard.set(self.isFirstOpen, forKey: self.isFirstOpenKey)
                            })
                            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
                    ).eraseToAnyPublisher()
                }
                if case .logout = state {
                    self.isFirstOpen = true
                    UserDefaults.standard.set(self.isFirstOpen, forKey: self.isFirstOpenKey)
                }

                return sessionState
            }
            .receive(on: DispatchQueue.main)
            .subscribe(transition)
            .store(in: &subscriptions)
    }
}
