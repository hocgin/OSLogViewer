import SwiftUI
import OSLog
import Combine

extension OSLogViewer {
    
    final class ViewModel: ObservableObject {

        private let logStore: OSLogStore = try! OSLogStore(scope: .currentProcessIdentifier)

        @Published var entries: [OSLogEntryLog] = []

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
                entries.filter { log in
                    log.composedMessage.lowercased().contains(searchText.lowercased())
                }
            }
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .assign(to: \ViewModel.searchForEntries, on: self)
            .store(in: &cancellables)
        }

        func reload() async {
            await MainActor.run {
                isLoading = true
            }

            let date = Date.now.addingTimeInterval(-24 * 3600)
            let position = logStore.position(date: date)

            do {
                let entries = try logStore.loadLogs(for: .init(position: position))

                var tmpSubsystems = Set<String>()

                var tmpCategories = Set<String>()

                entries.forEach { log in
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
                    self.entries = entries
                    self.allSubsystems = allSubsystems
                    self.allCategories = allCategories

                    selectAllSubsystems()

                    selectAllCategories()

                    isLoading = false
                }
            } catch  {

            }
        }

        var preferredEntries: [OSLogEntryLog] {
            if searchText.isEmpty {
                entries
            } else {
                searchForEntries
            }
        }

        var filteredEntries: [OSLogEntryLog] {
            preferredEntries.filter { log in
                selectedSubsystems.contains(log.subsystem)
            }.filter { log in
                selectedCategories.contains(log.category)
            }
        }

        func selectAllSubsystems() {
            selectedSubsystems = Set(allSubsystems)
        }

        func selectAllCategories() {
            selectedCategories = Set(allCategories)
        }
    }
}
