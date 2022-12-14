import SwiftUI

<<<<<<<< HEAD:FirebaseUserStore/App/Feed/Views/FeedView.swift
struct FeedView<Service: SessionService, Store: FeedStore>: View {
    var service: Service
    @EnvironmentObject var store: Store
//    @EnvironmentObject var viewModel: HomeViewModel
    
    @State var showAbout = false
========
struct FeedView: View {
    @EnvironmentObject var store: FeedStore
    
>>>>>>>> redux:FirebaseUserStore/App/Feed/View/FeedView.swift
    @State var showLoader = false
    let heights = stride(from: 0.1, through: 1.0, by: 0.1).map { PresentationDetent.fraction($0) }
    
    @State var isRefresh = false
    let userDetailStore = SessionService.shared.userDetails
    var body: some View {
        mainView
    }
    
    @ViewBuilder
    var mainView: some View {
        VStack {
            VStack(alignment: .leading,
                   spacing: 16) {

                HStack {
                    Spacer()
                    Button {
<<<<<<<< HEAD:FirebaseUserStore/App/Feed/Views/FeedView.swift
                        store.dispatch(.showAboutSheet(serviceData: service.makeSlice))
========
                        store.dispatch(.showAboutSheet)
>>>>>>>> redux:FirebaseUserStore/App/Feed/View/FeedView.swift
                    } label: {
                        Image(systemName: "person")
                    }
                }
                .padding()
            }
                   .padding(.horizontal, 16)

            NavigationView {
                    List {
                        ForEach(store.state.items) {
                            Text($0.title)
                        }
                        .onDelete {
                            let idsToDelete = $0.map { self.store.state.items[$0].id }
                            guard let id = idsToDelete.first else { return }

                            store.dispatch(.removeItem(id: id))
                        }

                    }
            }
<<<<<<<< HEAD:FirebaseUserStore/App/Feed/Views/FeedView.swift
            .disabled(isRefresh)
            .opacity(isRefresh ? 0.5 : 1)
========
            .modifier(ProgressViewModifier(provider: store.state.viewProgress))
>>>>>>>> redux:FirebaseUserStore/App/Feed/View/FeedView.swift
            
            ButtonView(title: "NEW") {
                store.dispatch(.addItem)
            }
            .modifier(ButtonProgressViewModifier(provider: store.state.buttonProgress))
            .padding()
            
            ButtonView(title: "FLUX") {
                store.dispatch(.updateFeed)
            }
            .padding()

            ButtonView(title: "LOGOUT") {
                SessionService.shared.userDetails = nil
            }
            .padding()

            ButtonView(title: "LOGIN") {
                SessionService.shared.login()
            }
            .padding()
        }
<<<<<<<< HEAD:FirebaseUserStore/App/Feed/Views/FeedView.swift
        .modifier(AlertShowViewModifier(provider: store.state.alertProvider))
        .modifier(SheetShowViewModifier(provider: store.state.aboutSheetProvider))
========

        .modifier(AlertShowViewModifier(provider: store.state.alert))
        .modifier(SheetShowViewModifier(provider: store.state.aboutSheetProvider))
        .modifier(ProcessViewModifier(provider: store.state.processViewProgress))
>>>>>>>> redux:FirebaseUserStore/App/Feed/View/FeedView.swift
        .onAppear {
            store.dispatch(.updateFeed)
        }
    }
        
}



extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}

<<<<<<<< HEAD:FirebaseUserStore/App/Feed/Views/FeedView.swift
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedView(service: MockSessionServiceImpl())
                .environmentObject(
                    StateStore(
                        state: FeedState(),
                        dispatcher: FeedDispatcher(environment: ItemsService()),
                        reducer: feedReducer
                    )
                )
        }
    }
}
========
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            FeedView()
//                .environmentObject(
//                    StateStore(
//                        state: FeedState(),
//                        dispatcher: loginDispatcher,
//                        reducer: feedReducer,
//                        packages: FeedPackages()
//                    )
//                )
//        }
//    }
//}
>>>>>>>> redux:FirebaseUserStore/App/Feed/View/FeedView.swift
