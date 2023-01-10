import Foundation
import FirebaseAuth
import FirebaseDatabase
import Combine

protocol SessionServiceType: ObservableObject {
    var state: SessionState { get }
    var userDetails: UserDetails? { get }

    func logout()
}

struct SessionServiceSlice {
    let state: SessionState
    let userDetails: UserDetails?
    let logout: () -> ()
}

final class SessionService: SessionServiceType, ObservableObject {
    static let shared = SessionService()
    @Published var state: SessionState = .loading
    @Published var userDetails: UserDetails?
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        setupObservations()
    }

    func login() {
        let auth = self.auth()
            .retry(3)
            .replaceError(with: nil)
            .share()

        auth
            .compactMap { $0 }
            .assign(to: &$userDetails)
        
        auth
            .map { $0 == nil ? SessionState.loggedOut : SessionState.loggedIn }
            .assertNoFailure()
            .assign(to: &$state)
    }

    func logout() {
        try? Auth.auth().signOut()
    }
}
var isError = true
private extension SessionService {
    func setupObservations() {
        handler = Auth
            .auth()
            .addStateDidChangeListener { [weak self] _,_ in
                guard let self = self else { return }
                
                let currentUser = Auth.auth().currentUser

                
                if let uid = currentUser?.uid {
                    Database
                        .database()
                        .reference()
                        .child("users")
                        .child(uid)
                        .observe(.value) { [weak self] snapshot in
                            guard let self = self,
                                  let value = snapshot.value as? NSDictionary,
                                  let firstName = value[RegistrationKeys.firstName.rawValue] as? String,
                                  let lastName = value[RegistrationKeys.lastName.rawValue] as? String,
                                  let occupation = value[RegistrationKeys.occupation.rawValue] as? String,
                                  let currentUser = currentUser else {
                                self?.state = .loggedOut
                                return
                            }

                            DispatchQueue.main.async {
                                self.state = .loggedIn
                                self.userDetails = UserDetails(
                                    storage: UserStorageDetails(
                                        firstName: firstName,
                                        lastName: lastName,
                                        occupation: occupation),
                                    auth: UserAuthDetails(email: (mail: currentUser.email ?? "", isVerified: currentUser.isEmailVerified))
                                )
                            }
                        }
                } else {
                    self.state = .loggedOut
                }
            }
    }

    private func auth() -> AnyPublisher<UserDetails?, SessionServiceError>  {
        Deferred {
            Future { promise in
                let currentUser = Auth.auth().currentUser

                if let uid = currentUser?.uid {
                    Database
                        .database()
                        .reference()
                        .child("users")
                        .child(uid)
                        .observe(.value) { snapshot in
                            
                            guard
                                  let value = snapshot.value as? NSDictionary,
                                  let firstName = value[RegistrationKeys.firstName.rawValue] as? String,
                                  let lastName = value[RegistrationKeys.lastName.rawValue] as? String,
                                  let occupation = value[RegistrationKeys.occupation.rawValue] as? String,
                                  let currentUser = currentUser else {
                                return promise(.success(nil))
                            }
                            
                            let userDetails = UserDetails(
                                storage: UserStorageDetails(
                                    firstName: firstName,
                                    lastName: lastName,
                                    occupation: occupation),
                                auth: UserAuthDetails(email: (mail: currentUser.email ?? "", isVerified: currentUser.isEmailVerified))
                            )
                            promise(.success(userDetails))
                        }
                } else {
                    promise(.failure(.errorWithAuth))
                }
            }
        }
        .eraseToAnyPublisher()
    }
     
}

final class MockSessionService: SessionServiceType, ObservableObject {
    @Published var state: SessionState = .loggedOut
    @Published var userDetails: UserDetails? = UserDetails(
        storage: UserStorageDetails(firstName: "Name", lastName: "Surname", occupation: "Occupation"),
        auth: UserAuthDetails(email: (mail: "string@mail.com", isVerified: false))
        )

    var makeSlice: SessionServiceSlice { SessionServiceSlice(state: state, userDetails: nil, logout: logout) }
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    func logout() {}
}

enum SessionState {
    case loggedIn
    case loggedOut
    case loading
}

struct UserDetails {
    let storage: UserStorageDetails
    let auth: UserAuthDetails
}

struct UserStorageDetails {
    let firstName: String
    let lastName: String
    let occupation: String
}

struct UserAuthDetails {
    let email: (String, isVerified: Bool)
}
