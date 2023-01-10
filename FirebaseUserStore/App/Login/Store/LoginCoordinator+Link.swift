import Foundation
import SwiftUI
import Combine

enum LoginLink: TransitionType {
    case forgot
    case register(store: LoginStore)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .forgot:
            hasher.combine(0)
        case .register:
            hasher.combine(1)
        }
    }

    static func == (lhs: LoginLink, rhs: LoginLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class LoginTransitionState: ObservableObject {
    @Published var path = NavigationPath()
    @Published var fullcover: LoginLink?
    @Published var sheet: LoginLink?

    private var subscriptions = Set<AnyCancellable>()

    init<T: TransitionSender>(sender: T) where T.SenderTransitionType == LoginLink {
        sender.transition.sink {[weak self] transition in
            guard let self else { return }
            switch transition {
            case .forgot: self.fullcover = transition
            case .register: self.path.append(transition)
            }
        }
        .store(in: &subscriptions)
    }
}

struct LoginCoordinator<Content: View>: View {
    @ObservedObject var state: LoginTransitionState
    let root: Content

    var body: some View {
        NavigationStack(path: $state.path) {
            ZStack {
                root
                    .fullScreenCover(item: $state.fullcover, content: coverContent)
                    .sheet(item: $state.sheet, content: sheetContent)
            }
            .navigationDestination(for: LoginLink.self, destination: linkDestination)
        }
    }

    @ViewBuilder private func linkDestination(link: LoginLink) -> some View {
        switch link {
        case let .register(store):
            RegisterView(store: RegisterationStore(state: RegisterationState(), dispatcher: registerationDispatcher, reducer: registerationReducer, packages: RegisterationPackages()))
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func coverContent(link: LoginLink) -> some View {
        switch link {
        case .forgot:
            ForgotPasswordView(store: ForgotStore(state: ForgotState(), dispatcher: forgotDispatcher, reducer: forgotReducer, packages: ForgotPackages())).presentationDetents([.height(200), .medium])
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func sheetContent(link: LoginLink) -> some View {
        switch link {
        default:
            EmptyView()
        }
    }
}
