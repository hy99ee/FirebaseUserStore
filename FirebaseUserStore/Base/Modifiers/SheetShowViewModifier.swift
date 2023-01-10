import SwiftUI

protocol SheetProviderType: ObservableObject {
    associatedtype SheetView: View
    var sheetView: SheetView? { get set }
    var presentationDetent: Set<PresentationDetent> { get set }
}

class SheetProvider<SheetViewType>: SheetProviderType where SheetViewType: View {
    var presentationDetent: Set<PresentationDetent>
    @Published var sheetView: SheetViewType?

    init(presentationDetent: Set<PresentationDetent> = Set()) {
        self.presentationDetent = presentationDetent
    }
}

struct SheetShowViewModifier<SheetProvider: SheetProviderType>: ViewModifier {
    var provider: SheetProvider

    func body(content: Content) -> some View {
        let announcingResult = Binding<Bool>(
            get: { self.provider.sheetView != nil },
            set: { _ in self.provider.sheetView = nil }
        )
        content
            .sheet(isPresented: announcingResult) {
                self.provider.sheetView
                    .presentationDetents(self.provider.presentationDetent)
            }
    }
}
