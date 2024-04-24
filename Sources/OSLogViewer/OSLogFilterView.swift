import SwiftUI

struct OSLogFilterView: View {

    @EnvironmentObject
    private var viewModel: OSLogList.ViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 0) {

            VStack(alignment: .leading) {
                Text("Subsystem")
                    .font(.headline)
                    .padding(.leading, 5)

                Divider()

                ScrollView {
                    ForEach(viewModel.allSubsystems, id: \.self) { name in
                        VStack(alignment: .leading) {
                            Text("\(Image(systemName: viewModel.selectedSubsystems.contains(name) ? "checkmark.square" : "square")) \(name)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if viewModel.selectedSubsystems.contains(name) {
                                        viewModel.selectedSubsystems.remove(name)
                                    } else {
                                        viewModel.selectedSubsystems.insert(name)
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        viewModel.selectedSubsystems = [name]
                                    } label: {
                                        Label("Only select", systemImage: "heart")
                                    }

                                    Button {
                                        viewModel.selectAllSubsystems()
                                    } label: {
                                        Label("Select All", systemImage: "heart")
                                    }
                                }
                                .padding(.leading, 5)

                            Divider()
                        }
                    }
                }
                .clipped()
            }

            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            VStack(alignment: .leading) {
                Text("Category")
                    .font(.headline)
                    .padding(.leading, 5)

                Divider()

                ScrollView {
                    ForEach(viewModel.allCategories, id: \.self) { name in
                        VStack(alignment: .leading) {
                            Text("\(Image(systemName: viewModel.selectedCategories.contains(name) ? "checkmark.square" : "square")) \(name)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if viewModel.selectedCategories.contains(name) {
                                        viewModel.selectedCategories.remove(name)
                                    } else {
                                        viewModel.selectedCategories.insert(name)
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        viewModel.selectedCategories = [name]
                                    } label: {
                                        Label("Only select", systemImage: "heart")
                                    }

                                    Button {
                                        viewModel.selectAllCategories()
                                    } label: {
                                        Label("Select All", systemImage: "heart")
                                    }
                                }
                                .padding(.leading, 5)

                            Divider()
                        }
                    }
                }
                .clipped()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
    }
}

#Preview {
    let viewModel = OSLogList.ViewModel()
    viewModel.allSubsystems = ["A", "B", "C"]
    viewModel.allCategories = ["a", "b", "c"]

    return OSLogFilterView()
        .environmentObject(viewModel)
}
