import SwiftUI
import OSLog

public struct OSLogList: View {

    public init() { }

    @StateObject
    private var viewModel = ViewModel()

    @Environment(\.dismiss)
    private var dismiss

    public var body: some View {
        ZStack(alignment: .topLeading) {
            List(viewModel.filteredEntries) { entry in
                OSLogEntryRow(entry: entry)
            }
            .listStyle(.plain)

            .refreshable {
                await viewModel.reload()
            }
            .searchable(text: $viewModel.searchText)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }

            if viewModel.isFilterPresented {
                OSLogFilterView()
                    .environmentObject(viewModel)
                    .frame(maxHeight: 300)
            }
        }
        .navigationTitle("OSLog Viewer")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isExportPresented) {
            ActivityView(items: [viewModel.filteredEntries.map(\.composedMessage).joined(separator: "\n")])
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }

            ToolbarItem {
                Menu {
                    Button("Export", systemImage: "square.and.arrow.up") {
                        viewModel.isExportPresented.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }

            ToolbarItem {
                Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                    viewModel.isFilterPresented.toggle()
                }
            }
        }
        .onAppear(perform: {
            viewModel.isLoading = true

            Task {
                await viewModel.reload()

                viewModel.isLoading = false
            }
        })
    }
}
