struct Toast {
    var type: ToastType
    var message: String
}

extension Toast {
    var toastMessage: String {
        type.preffix + message + type.suffix
    }
}

enum ToastType {
    case error(Error), success, userError
}

extension ToastType {
    var preffix: String {
        switch self {
        case .error(_):
            return "⚠️ "
        case .userError:
            return "❌ "
        case .success:
            return "✅ "
        }
    }
    var suffix: String {
        switch self {
        case .error(let error):
            return " \(error.localizedDescription)"
        default: return ""
        }
    }
}
