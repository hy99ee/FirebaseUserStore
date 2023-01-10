import Foundation
import Combine
import SwiftUI

let registerationDispatcher: DispatcherType<RegisterationAction, RegisterationMutation, RegisterationPackages> = { action, packages in
    switch action {
    case let .clickRegisteration(user):
        return mutationRegisteration(user, packages: packages).withStatus(start: RegisterationMutation.progressStatus(.start), finish: RegisterationMutation.progressStatus(.stop))
    }

    func mutationRegisteration(_ user: RegistrationCredentials, packages: RegisterationPackages) -> AnyPublisher<RegisterationMutation, Never> {
        packages.registerationService.register(with: user)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { RegisterationMutation.close }
            .catch { _ in Just(RegisterationMutation.errorAlert(error: RegistrationServiceError.undefined)) }
            .eraseToAnyPublisher()
    }
}

