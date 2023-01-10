import SwiftUI

enum ProgressViewStatus {
    case start
    case stop

    mutating func toggle() {
        if self == .stop { self = .start }
        else { self = .stop }
    }
}

class ProgressViewProvider: ProgressViewProviderType {
    @Published var progressStatus: ProgressViewStatus = .stop
}
