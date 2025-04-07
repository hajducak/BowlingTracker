import Foundation
import Combine
import SwiftUI

class TooltipViewModel: ObservableObject {
    @Published var tooltipText: String? = nil
    private var tooltipTimer: DispatchWorkItem? = nil
    
    func showTooltip(text: String) {
        tooltipTimer?.cancel()
        
        tooltipText = text
        let newTimer = DispatchWorkItem { [weak self] in
            withAnimation {
                self?.tooltipText = nil
            }
        }
        tooltipTimer = newTimer
        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: newTimer)
    }
    
    func dismissTooltipIfShowing() {
        if tooltipText != nil {
            tooltipTimer?.cancel()
            tooltipText = nil
        }
    }
}
