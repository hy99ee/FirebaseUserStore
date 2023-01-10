import SwiftUI
import Combine

struct RegisterView: View {
    @StateObject var store: RegisterationStore
    @State var newUser = RegistrationCredentials(email: "", password: "", firstName: "", lastName: "", occupation: "")
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    InputTextFieldView(text: $newUser.email,
                                       placeholder: "Email",
                                       keyboardType: .emailAddress,
                                       systemImage: "envelope")

                    InputPasswordView(password: $newUser.password,
                                      placeholder: "Password",
                                      systemImage: "lock")

                    Divider()

                    InputTextFieldView(text: $newUser.firstName,
                                       placeholder: "First Name",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)

                    InputTextFieldView(text: $newUser.lastName,
                                       placeholder: "Last Name",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)

                    InputTextFieldView(text: $newUser.occupation,
                                       placeholder: "Occupation",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)
                }

                ButtonView(title: "Sign up") {
                    store.dispatch(.clickRegisteration(user: newUser))
                }
                .modifier(ButtonProgressViewModifier(provider: store.state.progress, type: .buttonView))
            }
            .padding(.horizontal, 15)
            .navigationTitle("Register")
            .modifier(AlertShowViewModifier(provider: store.state.alert))
        }
    }
}
