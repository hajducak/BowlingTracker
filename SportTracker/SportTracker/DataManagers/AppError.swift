import Foundation

enum AppError: Error, LocalizedError {
    case fetchingError(Error)
    case saveError(Error)
    case deletingError(Error)
    case unknownError
    case invalidInput
    case customError(String)

    var errorMessage: String {
        switch self {
        case .fetchingError(let error):
            return "Error occures while fetching performances: \(error.localizedDescription)"
        case .saveError(let error):
            return "Error occures while saving to Database: \(error.localizedDescription)"
        case .deletingError(let error):
            return "Error occures while deleting performance: \(error.localizedDescription)"
        case .invalidInput:
            return "Please fill in all fields correctly."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        case .customError(let message):
            return message
        }
    }
}
