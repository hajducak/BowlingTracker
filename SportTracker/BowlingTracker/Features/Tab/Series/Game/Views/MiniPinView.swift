import SwiftUI

struct MiniPinView: View {
    let firstRollPins: [Pin]?
    let secondRollPins: [Pin]?
    
    let innerSpacing: CGFloat = Padding.spacingXXS
    let rowSpacing: CGFloat = Padding.spacingXXXS

    var body: some View {
        VStack(spacing: rowSpacing) {
            HStack(spacing: innerSpacing) {
                PinCircle(id: 7, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
                PinCircle(id: 8, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
                PinCircle(id: 9, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
                PinCircle(id: 10, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
            }
            HStack(spacing: innerSpacing) {
                PinCircle(id: 4, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
                PinCircle(id: 5, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
                PinCircle(id: 6, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
            }
            HStack(spacing: innerSpacing) {
                PinCircle(id: 2, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
                PinCircle(id: 3, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
            }
            HStack(spacing: innerSpacing) {
                PinCircle(id: 1, firstRollPins: firstRollPins, secondRollPins: secondRollPins)
            }
        }
    }
}

struct PinCircle: View {
    let id: Int
    let firstRollPins: [Pin]?
    let secondRollPins: [Pin]?

    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(
                firstRollPins == nil && secondRollPins == nil ? Color(.bgPrimary) :
                firstRollPins?.contains(where: { $0.id == id }) == true ? Color(.bgSecondary) :
                secondRollPins?.contains(where: { $0.id == id }) == true ? Color(.complementary) :
                Color(.primary)
            )
    }
}

#Preview {
    VStack {
        Text("S prvým a druhým hodom")
        MiniPinView(
            firstRollPins: [Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5), Pin(id: 6), Pin(id: 8), Pin(id: 9)],
            secondRollPins: [Pin(id: 7)]
        )
        
        Text("Len s prvým hodom")
        MiniPinView(
            firstRollPins: [Pin(id: 1), Pin(id: 2), Pin(id: 3)],
            secondRollPins: nil
        )
        
        Text("Len s druhým hodom")
        MiniPinView(
            firstRollPins: nil,
            secondRollPins: [Pin(id: 4), Pin(id: 5), Pin(id: 6)]
        )
        
        Text("Žiadne hody (všetko čierne)")
        MiniPinView(firstRollPins: nil, secondRollPins: nil)
    }
}
