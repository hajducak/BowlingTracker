import SwiftUI

struct SeriesPopupView: View {
    @Binding var isVisible: Bool
    @Binding var seriesName: String
    @Binding var selectedType: SeriesType
    @Binding var selectedDate: Date
    var onSave: () -> Void

    var body: some View {
        BasicPopup(
            isVisible: $isVisible,
            title: "Create new series"
        ) {
            Group {
                Text("Series name")
                    .font(.system(size: 14, weight: .medium))
                TextField("Enter series name", text: $seriesName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("Select type", selection: $selectedType) {
                    Text("League").tag(SeriesType.league)
                    Text("Tournament").tag(SeriesType.tournament)
                    Text("Training").tag(SeriesType.training)
                    Text("Other").tag(SeriesType.other)
                }
                .pickerStyle(SegmentedPickerStyle())
                .font(.system(size: 14, weight: .medium))
                
                DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .font(.system(size: 14, weight: .medium))
            }.padding(.horizontal, Padding.defaultPadding)
        } onConfirm: {
            if !seriesName.isEmpty { // TODO: texfield validation
                onSave()
            }
        }
    }
}

#Preview {
    SeriesPopupView(
        isVisible: .constant(true),
        seriesName: .constant(""),
        selectedType: .constant(.other),
        selectedDate: .constant(Date.now)
    ) { }
}
