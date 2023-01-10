import SwiftUI
import Combine

struct LoginState: StateType {
    let alert = AlertProvider()

    let loginProgress = ProgressViewProvider()
    let registerProgress = ProgressViewProvider()
    let forgotProgress = ProgressViewProvider()

    let processView: ProcessViewProvider

    init() {
        processView = ProcessViewProvider(loginProgress, registerProgress, forgotProgress)
    }
}
