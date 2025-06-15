import SwiftUI
import OSLog
import Combine

public struct OSLogViewer: View {

    public init() { }

    @StateObject
    private var viewModel = ViewModel()

    @Environment(\.dismiss)
    private var dismiss

    public var body: some View {
        ZStack(alignment: .topLeading) {
            List(viewModel.displayLogs, id: \.self) { entry in
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
            ActivityView(items: [viewModel.displayLogs.map(\.composedMessage).joined(separator: "\n")])
        }
        .toolbar {
            defaultToolbar
        }
        .task {
            await viewModel.reload()
        }
        .onChange(of: viewModel.selectedCategories) { _ in
            viewModel.updateSelectLog()
        }
        .onChange(of: viewModel.selectedSubsystems) { _ in
            viewModel.updateSelectLog()
        }
    }

    @ToolbarContentBuilder
    var defaultToolbar: some ToolbarContent {
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
}

extension OSLogViewer {

    @MainActor final class ViewModel: ObservableObject {

        private let logStore: OSLogStore = try! OSLogStore(scope: .currentProcessIdentifier)

        @Published var displayLogs: [OSLogEntryLog] = []

        private var entries: [OSLogEntryLog] = []

        @Published var searchForEntries: [OSLogEntryLog] = []

        @Published var allCategories = [String]()

        @Published var selectedCategories = Set<String>()

        @Published var allSubsystems = [String]()

        @Published var selectedSubsystems = Set<String>()

        @Published var isFilterPresented = false

        @Published var isLoading = false

        @Published var isExportPresented = false

        @Published var searchText: String = ""

        private var cancellables = Set<AnyCancellable>()

        init() {
            $searchText.map { [self] text in
                if searchText.isEmpty {
                    entries.filter { log in
                        selectedSubsystems.contains(log.subsystem)
                    }.filter { log in
                        selectedCategories.contains(log.category)
                    }
                } else {
                    entries.filter { log in
                        log.composedMessage.lowercased().contains(searchText.lowercased())
                    }
                }
            }
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .assign(to: \ViewModel.displayLogs, on: self)
            .store(in: &cancellables)
        }

        func reload() async {
            isLoading = true

            if let entries = try? await logStore.getLogs(for: .init()) {
                await parseLogs(entries)

                self.entries = entries

                self.displayLogs = self.entries

                selectAllSubsystems()

                selectAllCategories()
            }

            isLoading = false
        }

        nonisolated func parseLogs(_ logs: [OSLogEntryLog]) async {
            var tmpSubsystems = Set<String>()

            var tmpCategories = Set<String>()

            logs.forEach { log in
                if !tmpSubsystems.contains(log.subsystem) && !log.subsystem.isEmpty {
                    tmpSubsystems.insert(log.subsystem)
                }

                if !tmpCategories.contains(log.category) && !log.category.isEmpty  {
                    tmpCategories.insert(log.category)
                }
            }

            let allSubsystems = Array(tmpSubsystems).sorted()

            let allCategories =  Array(tmpCategories).sorted()

            await MainActor.run {
                self.allSubsystems = allSubsystems
                self.allCategories = allCategories
            }
        }

         func updateSelectLog()  {
            let tmp = entries.filter { log in
                selectedSubsystems.contains(log.subsystem)
            }.filter { log in
                selectedCategories.contains(log.category)
            }

             displayLogs = tmp
        }

        func selectAllSubsystems() {
            selectedSubsystems = Set(allSubsystems)
        }

        func selectAllCategories() {
            selectedCategories = Set(allCategories)
        }
    }
}


#Preview {
    OSLogViewer()
}
