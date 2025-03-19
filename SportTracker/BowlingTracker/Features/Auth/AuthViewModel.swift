import Foundation
import Combine
import FirebaseAuth

final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var toast: Toast?
    @Published var shouldRememberCredentials = false
    
    private let authService: AuthServiceProtocol
    private let keychainService: KeychainService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol, keychainService: KeychainService = .shared) {
        self.authService = authService
        self.keychainService = keychainService
        checkAuthenticationState()
        tryLoadSavedCredentials()
    }
    
    private func checkAuthenticationState() {
        isAuthenticated = authService.getCurrentUser() != nil
    }
    
    private func tryLoadSavedCredentials() {
        do {
            let credentials = try keychainService.getCredentials()
            email = credentials.email
            password = credentials.password
            shouldRememberCredentials = true
        } catch { }
    }
    
    func signIn() {
        isLoading = true
        authService.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                handleSuccessfulAuth()
            }
            .store(in: &cancellables)
    }
    
    func signUp() {
        isLoading = true
        authService.signUp(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                handleSuccessfulAuth()
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        isLoading = true
        authService.signOut()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    toast = Toast(type: .error(error))
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                isAuthenticated = false
                email = ""
                password = ""
                do {
                    try keychainService.deleteCredentials()
                } catch {
                    toast = Toast(type: .error(.customError("Failed to clear saved credentials")))
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleSuccessfulAuth() {
        isAuthenticated = true
        if shouldRememberCredentials {
            do {
                try keychainService.saveCredentials(email: email, password: password)
            } catch {
                toast = Toast(type: .error(.customError("Failed to save credentials")))
            }
        }
        toast = Toast(type: .success("Successfully authenticated"))
    }
    
    deinit {
        cancellables.removeAll()
    }
} 
