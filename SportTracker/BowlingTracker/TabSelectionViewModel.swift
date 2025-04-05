import SwiftUI

class TabSelectionViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectProfileTab),
            name: .selectProfileTab,
            object: nil
        )
    }
    
    @objc private func handleSelectProfileTab() {
        DispatchQueue.main.async {
            self.selectProfileTab()
        }
    }
    
    func selectAddTab() {
        selectedTab = 0
    }

    func selectListTab() {
        selectedTab = 1
    }

    func selectProfileTab() {
        selectedTab = 2
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
