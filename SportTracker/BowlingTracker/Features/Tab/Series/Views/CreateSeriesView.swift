import SwiftUI

struct CreateSeriesView: View {
    let title: String
    @Binding var seriesName: String
    @Binding var seriesDescription: String
    @Binding var seriesOilPatternName: String
    @Binding var seriesOilPatternURL: String
    @Binding var seriesHouse: String
    @Binding var selectedType: SeriesType
    @Binding var selectedDate: Date
    var onSave: (() -> Void)?
    var onClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Padding.spacingXXM) {
                    Text(title).title()
                    TextField("Enter series name", text: $seriesName)
                        .defaultTextFieldStyle(labeled: "Series name")
                    TextField("Enter series description", text: $seriesDescription)
                        .defaultTextFieldStyle(labeled: "Series description")
                    TextField("Enter oil pattern name", text: $seriesOilPatternName)
                        .defaultTextFieldStyle(labeled: "Enter series oil pattern")
                    TextField("Enter oil pattern URL", text: $seriesOilPatternURL)
                        .defaultTextFieldStyle()
                    TextField("Enter house name", text: $seriesHouse)
                        .defaultTextFieldStyle(labeled: "House")
                    Picker("Select type", selection: $selectedType) {
                        Text("League").tag(SeriesType.league)
                        Text("Tournament").tag(SeriesType.tournament)
                        Text("Practise").tag(SeriesType.practise)
                        Text("Other").tag(SeriesType.other)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .heading()
                    .labled(label: "Type of series")
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .tint(Color(.primary))
                        .background(DefaultColor.grey6.cornerRadius(Corners.corenrRadiusS))
                        .labled(label: "Select date")
                    DatePicker("", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        .background(DefaultColor.grey6.cornerRadius(Corners.corenrRadiusS))
                        .labled(label: "Select time")
                    Spacer()
                }
                .padding(.horizontal, Padding.defaultPadding)
                .padding(.bottom, 100)
            }
            buttons
                .padding(.vertical, Padding.defaultPadding)
                .padding(.bottom, Padding.defaultPadding)
                .background {
                    RoundedRectangle(cornerRadius: Corners.corenrRadiusL)
                        .fill(Color(.bgSecondary))
                }
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(.bgPrimary))
    }

    private var buttons: some View {
        HStack {
            SecondaryButton(
                title: "Close",
                isLoading: false,
                isEnabled: true,
                backgroundColor: Color(.bgSecondary),
                action: onClose
            )
            Spacer()
            onSave.map { _ in
                PrimaryButton(
                    title: "Save",
                    isLoading: false,
                    isEnabled: true,
                    action: { onSave?() }
                )
            }
        }
        .padding(.horizontal, Padding.defaultPadding)
    }
}

#Preview {
    CreateSeriesView(
        title: "Create new series",
        seriesName: .constant(""),
        seriesDescription: .constant(""),
        seriesOilPatternName: .constant(""),
        seriesOilPatternURL: .constant(""),
        seriesHouse: .constant(""),
        selectedType: .constant(.other),
        selectedDate: .constant(Date.now)
    ) { }
}
