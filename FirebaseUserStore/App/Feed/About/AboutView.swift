import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct AboutViewData {
    let user: UserDetails
    let logout: () -> ()
}

struct AboutView: View {
    let user: UserDetails
    let logout: () -> ()

    private let actions = ["Logout", "Remove account"]
    private let accountImageSize = 80.0

    init(aboutData: AboutViewData) {
        self.user = aboutData.user
        self.logout = aboutData.logout
    }

    var body: some View {
        VStack {
            Text(
                String(user.storage.firstName.first ?? Character(" ")) +
                String(user.storage.lastName.first ?? Character(" "))
            )
            .font(.largeTitle)
            .frame(width: accountImageSize, height: accountImageSize, alignment: .center)
            .overlay(
                Text("Edit")
                    .padding(.bottom, 3)
                    .padding(.leading, 2)
                    .frame(width: accountImageSize)
                    .font(.system(size: 12).smallCaps())
                    .background(.black)
                    .foregroundColor(.gray),
                alignment: .bottom
            )
            .background(Color.random)
            .cornerRadius(accountImageSize / 2)
            .padding(.top, 30)
            
            VStack {
                Text(user.storage.firstName).font(.title).fontWeight(.semibold)
                Text(user.auth.email.0).font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            }
            .padding()

            NavigationView {
                
                Form {
                    Section("account") {
                        Button {
                            logout()
                        } label: {
                            Text("Logout").foregroundColor(.primary)
                        }

                        Button {
                            
                        } label: {
                            Text("Remove account").foregroundColor(.red)
                        }
                    }
                }
                .scrollDisabled(true)
            }
        }
    }
}

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var firstName = "Mock first name"
    static var lastName = "Mock last name"
    static var mail = "mail@mail.com"

    static var previews: some View {
        AboutView(aboutData: AboutViewData(user: UserDetails(storage: UserStorageDetails(firstName: firstName, lastName: lastName, occupation: "Occupation"), auth: UserAuthDetails(email: ("mockmail@mail.ru", isVerified: true))), logout: {}) )
    }
}
