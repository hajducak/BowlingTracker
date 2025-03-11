import SwiftUI

struct FilterTypes: Identifiable {
    let id: String = UUID().uuidString
    let type: SeriesType?
    let name: String
}

struct FilterView: View {
    @Binding var selectedFilter: SeriesType?
    
    private let types: [FilterTypes] = [
        FilterTypes(type: nil, name: "All"),
        FilterTypes(type: .tournament, name: "Tournaments"),
        FilterTypes(type: .league, name: "Leagues"),
        FilterTypes(type: .training, name: "Trainings"),
        FilterTypes(type: .other, name: "Others")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(types) { filter in
                    filterButton(filter)
                        .padding(.bottom, Padding.spacingXXXS)
                }
            }
            .padding(.horizontal, Padding.defaultPadding)
        }
    }
    
    private func filterButton(_ filter: FilterTypes) -> some View {
        let isSelected = selectedFilter == filter.type
        
        return Text(filter.name)
            .subheading(color: isSelected ? .white : DefaultColor.grey2, weight: .regular)
            .padding(.vertical, Padding.spacingXXS)
            .padding(.horizontal, Padding.spacingXXM)
            .background(isSelected ? Color.orange: DefaultColor.grey6)
            .clipShape(RoundedRectangle(cornerRadius: Corners.corenrRadiusL))
            .overlay(
                RoundedRectangle(cornerRadius: Corners.corenrRadiusL)
                    .stroke(isSelected ? Color.orange : DefaultColor.grey2, lineWidth: 1)
            )
            .animation(.easeInOut, value: isSelected)
            .tap {
                withAnimation { selectedFilter = filter.type }
            }
    }
}

#Preview {
    FilterView(selectedFilter: .constant(nil))
}
