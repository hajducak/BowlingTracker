import SwiftUI
import Combine

struct RollView: View {
    @State private var selectedPins: Set<Int> = []
    var game: Game
    var addRoll: ([Int]) -> ()
    
    var body: some View {
        VStack {
            Text("Select Fallen Pins")
                .font(.headline)
            
            PinsGrid(selectedPins: $selectedPins)
                .padding()
            
            Button(action: addRollforPins) {
                Text("Add Roll")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(selectedPins.isEmpty)
            .padding()
        }
        .padding()
    }
    
    // MARK: - Add Roll to Current Frame
    private func addRollforPins() {
        addRoll(Array(selectedPins))
        selectedPins.removeAll()
    }
}

#Preview {
    RollView(game: Game(), addRoll: { pins in print(pins) })
        .padding()
}


struct PinsGrid: View {
    @Binding var selectedPins: Set<Int>
    
    let pinLayout: [[Int]] = [
        [7, 8, 9, 10],
        [4, 5, 6],
        [2, 3],
        [1]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(pinLayout, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { pin in
                        PinView(pin: pin, isSelected: selectedPins.contains(pin)) {
                            togglePin(pin)
                        }
                    }
                }
            }
        }
    }
    
    private func togglePin(_ pin: Int) {
        if selectedPins.contains(pin) {
            selectedPins.remove(pin)
        } else {
            selectedPins.insert(pin)
        }
    }
}

struct PinView: View {
    let pin: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text("\(pin)")
            .frame(width: 40, height: 40)
            .background(isSelected ? Color.red : Color.gray.opacity(0.3))
            .foregroundColor(.black)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 1))
            .tap { onTap() }
    }
}
