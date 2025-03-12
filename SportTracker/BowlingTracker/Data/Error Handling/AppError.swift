import Foundation

enum AppError: Error, LocalizedError, Equatable {
    case fetchingError(Error)
    case saveError(Error)
    case deletingError(Error)
    case unknownError
    case invalidInput
    case customError(String)

    var errorMessage: String {
        switch self {
        case .fetchingError(let error):
            return "Error occurred while fetching performances: \(error.localizedDescription)"
        case .saveError(let error):
            return "Error occurred while saving to Database: \(error.localizedDescription)"
        case .deletingError(let error):
            return "Error occurred while deleting performance: \(error.localizedDescription)"
        case .invalidInput:
            return "Please fill in all fields correctly."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        case .customError(let message):
            return message
        }
    }

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.fetchingError(let lhsError), .fetchingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.saveError(let lhsError), .saveError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.deletingError(let lhsError), .deletingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.unknownError, .unknownError),
             (.invalidInput, .invalidInput):
            return true
        case (.customError(let lhsMessage), .customError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
