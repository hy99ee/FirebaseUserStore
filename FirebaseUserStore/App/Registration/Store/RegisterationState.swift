import SwiftUI
import Combine

struct RegisterationState: StateType {
    var firstIsValid = true
    var secondIsValid = true

    let alert = AlertProvider()
    let progress = ProgressViewProvider()
    let processView: ProcessViewProvider

    init() {
        processView = ProcessViewProvider(progress)
    }
}
