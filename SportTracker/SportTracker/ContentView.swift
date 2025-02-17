import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Sport Performance App")
            .font(.title)
            .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SportPerformance.self, inMemory: true)
}
