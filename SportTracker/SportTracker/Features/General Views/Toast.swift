struct Toast {
    var type: ToastType
}

extension Toast {
    var toastMessage: String { type.message }
}

enum ToastType {
    case error(AppError), success(String)
}

extension ToastType {
    var message: String {
        switch self {
        case .error(let error):
            return "⚠️ \(error.errorMessage)"
        case .success(let message):
            return "✅ \(message)"
        }
    }
}
