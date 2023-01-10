import Foundation
import Combine

enum LoginMutation: Mutation {
    case showRegister(store: LoginStore)
    case showForgot
    
    case login(user: LoginCredentials)
    case create(user: RegistrationCredentials)

    case progressLoginStatus(_ status: ProgressViewStatus)
    case progressRegisterStatus(_ status: ProgressViewStatus)

    case errorAlert(error: Error)
    case errorWithRegister
}

