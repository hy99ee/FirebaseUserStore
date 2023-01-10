import Foundation
import Combine
import SwiftUI

let loginDispatcher: DispatcherType<LoginAction, LoginMutation, LoginPackages> = { action, packages in
    switch action {
    case let .openRegister(store):
        return Just(LoginMutation.showRegister(store: store)).eraseToAnyPublisher()
        
    case .openForgot:
        return Just(LoginMutation.showForgot).eraseToAnyPublisher()
        
    case let .clickLogin(user):
        return mutationLogin(user, packages: packages).withStatus(start: LoginMutation.progressLoginStatus(.start), finish: LoginMutation.progressLoginStatus(.stop))
    }


    // MARK: - Mutations
    func mutationLogin(_ user: LoginCredentials, packages: LoginPackages) -> AnyPublisher<LoginMutation, Never> {
        packages.loginService.login(with: user)
            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
            .map { LoginMutation.login(user: user) }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
}
