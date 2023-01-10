import Foundation

enum RegistrationServiceError: Error {
    case firebaseError(_ error: Error)
    case undefined
}
