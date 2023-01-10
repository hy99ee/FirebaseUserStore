import Foundation
import SwiftUI
import Combine

enum FeedLink: TransitionType {
    case about(_ data: AboutViewData)
    case detail(_ item: Item)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .about:
            hasher.combine(0)
        case .detail:
            hasher.combine(1)
        }
    }

    static func == (lhs: FeedLink, rhs: FeedLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class FeedTransitionState: ObservableObject {
    @Published var path = NavigationPath()
    @Published var fullcover: FeedLink?
    @Published var sheet: FeedLink?

    private var subscriptions = Set<AnyCancellable>()

    init<T: TransitionSender>(sender: T) where T.SenderTransitionType == FeedLink {
        sender.transition.sink {[weak self] transition in
            guard let self else { return }
            switch transition {
            case .about: self.sheet = transition
            case .detail: self.path.append(transition)
            }
        }
        .store(in: &subscriptions)
    }
}

struct FeedCoordinator<Content: View>: View {
    @ObservedObject var state: FeedTransitionState
    let root: Content

    var body: some View {
        NavigationStack(path: $state.path) {
            ZStack {
                root
                    .sheet(item: $state.sheet, content: sheetContent)
            }
            .navigationDestination(for: FeedLink.self, destination: linkDestination)
        }
    }

    @ViewBuilder private func linkDestination(link: FeedLink) -> some View {
        switch link {
        case let .detail(item):
            Text(item.title)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func sheetContent(link: FeedLink) -> some View {
        switch link {
        case let .about(data):
            AboutView(aboutData: data).presentationDetents([.height(200), .medium])
        default:
            EmptyView()
        }
    }
}
