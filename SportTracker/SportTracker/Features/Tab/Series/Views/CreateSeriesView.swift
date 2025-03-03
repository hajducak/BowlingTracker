import SwiftUI

struct CreateSeriesView: View {
    @Binding var seriesName: String
    @Binding var seriesDescription: String
    @Binding var selectedType: SeriesType
    @Binding var selectedDate: Date
    var onSave: (() -> Void)?
    var onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Create new series")
                    .font(.largeTitle).bold()
                TextField("Enter series name", text: $seriesName)
                    .textFieldStyle(labeled: "Series name")
                TextField("Enter series description", text: $seriesDescription)
                    .textFieldStyle(labeled: "Series description")
                Picker("Select type", selection: $selectedType) {
                    Text("League").tag(SeriesType.league)
                    Text("Tournament").tag(SeriesType.tournament)
                    Text("Training").tag(SeriesType.training)
                    Text("Other").tag(SeriesType.other)
                }
                .pickerStyle(SegmentedPickerStyle())
                .font(.system(size: 16, weight: .medium))
                .labled(label: "Type of series")
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .tint(.orange)
                    .background(UIColor.systemGray6.color.cornerRadius(8))
                    .labled(label: "Select date")
                Spacer()
            }
            .padding(.horizontal, Padding.defaultPadding)
            HStack {
                Button {
                    onClose()
                } label: {
                    Text("Close")
                        .font(.system(size: 16, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.orange)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange, lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
                Spacer()
                onSave.map { _ in
                    Button {
                        onSave?()
                    } label: {
                        Text("Save")
                            .font(.system(size: 16, weight: .bold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Padding.defaultPadding)
        }
    }
}

#Preview {
    CreateSeriesView(
        seriesName: .constant(""),
        seriesDescription: .constant(""),
        selectedType: .constant(.other),
        selectedDate: .constant(Date.now)
    ) { }
}
