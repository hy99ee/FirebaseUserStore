import SwiftUI
import Combine

enum GlobalLink: TransitionType {
    case login
    case logout

    case progress

    case promo

    var id: String {
        String(describing: self)
    }
}

class GlobalTransition: ObservableObject {
    @Published var core: GlobalLink = .progress
    @Published var promoSheet: GlobalLink?

    private var subscriptions = Set<AnyCancellable>()

    init<T: TransitionSender>(sender: T) where T.SenderTransitionType == GlobalLink {
        sender.transition.sink {[weak self] transition in
            guard let self else { return }
            switch transition {
            case .login:
                self.core = transition
            case .logout:
                self.core = transition
            case .progress:
                self.core = transition
            case .promo:
                self.promoSheet = transition
            }
        }
        .store(in: &subscriptions)
    
    }
}

struct GlobalCoordinator: View {
    @ObservedObject var state: GlobalTransition

    private let storeRepository = GlobalStoreRepository.shared

    var body: some View {
        linkDestination(link: state.core)
            .fullScreenCover(item: $state.promoSheet, content: coverContent)
    }

    @ViewBuilder private func linkDestination(link: GlobalLink) -> some View {
        switch link {
        case .progress:
            HDotsProgress().scaleEffect(2)
        case .login:
//            FeedView(store: storeRepository.feedStore)
            FeedCoordinator(state: FeedTransitionState(sender: storeRepository.feedStore), root: feedView)
        case .logout:
            LoginCoordinator(state: LoginTransitionState(sender: storeRepository.loginStore), root: loginView)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func coverContent(link: GlobalLink) -> some View {
        switch link {
        case .promo:
            ProgressView().background(.red).applyClose(.view)
        default:
            EmptyView()
        }
    }

    private var loginView: some View {
        LoginView().environmentObject(storeRepository.loginStore)
    }

    private var feedView: some View {
        FeedView(store: storeRepository.feedStore)
    }
}
