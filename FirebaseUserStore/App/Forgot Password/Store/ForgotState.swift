import SwiftUI
import Combine

struct ForgotState: StateType {
    var isValidEmailField = true
    let alert = AlertProvider()
    let progress = ProgressViewProvider()
    let processView: ProcessViewProvider

    init() {
        processView = ProcessViewProvider(progress)
    }
}
