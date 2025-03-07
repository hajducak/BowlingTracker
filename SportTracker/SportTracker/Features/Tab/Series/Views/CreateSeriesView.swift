import SwiftUI

struct CreateSeriesView: View {
    @Binding var seriesName: String
    @Binding var seriesDescription: String
    @Binding var selectedType: SeriesType
    @Binding var selectedDate: Date
    var onSave: (() -> Void)?
    var onClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Create new series")
                        .title()
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
                    .heading()
                    .labled(label: "Type of series")
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .tint(.orange)
                        .background(DefaultColor.grey6.cornerRadius(8))
                        .labled(label: "Select date")
                    Spacer()
                }
                .padding(.horizontal, Padding.defaultPadding)
                .padding(.bottom, 100)
            }
            buttons
                .padding(.vertical, Padding.defaultPadding)
                .padding(.bottom, Padding.defaultPadding)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .stroke(DefaultColor.border, lineWidth: 1)
                }
        }.edgesIgnoringSafeArea(.bottom)
    }

    private var buttons: some View {
        HStack {
            Button {
                onClose()
            } label: {
                Text("Close")
                    .heading(color: .orange)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
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
                        .heading(color: .white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Padding.defaultPadding)
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
