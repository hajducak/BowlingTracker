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
        let color = filter.type?.color ?? Color.gray
        
        return Text(filter.name)
            .subheading(color: isSelected ? .white : color, weight: .regular)
            .padding(.vertical, Padding.spacingXXS)
            .padding(.horizontal, Padding.spacingXXM)
            .background(isSelected ? color.opacity(1) : color.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: Corners.corenrRadiusL))
            .overlay(
                RoundedRectangle(cornerRadius: Corners.corenrRadiusL)
                    .stroke(color, lineWidth: 1)
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
