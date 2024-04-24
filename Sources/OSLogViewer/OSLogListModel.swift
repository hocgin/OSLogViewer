import SwiftUI
import OSLog

extension OSLogList {
    
    @MainActor
    final class ViewModel: ObservableObject {

        private let logStore: OSLogStore = try! OSLogStore(scope: .currentProcessIdentifier)

        @Published var entries: [OSLogEntryLog] = []

        @Published var allCategories = [String]()

        @Published var selectedCategories = Set<String>()

        @Published var allSubsystems = [String]()

        @Published var selectedSubsystems = Set<String>()

        @Published var isFilterPresented = false

        @Published var isLoading = false

        @Published var isExportPresented = false

        @Published var searchText: String = ""

        func reload() async {
//            isLoading = true

            let date = Date.now.addingTimeInterval(-24 * 3600)
            let position = logStore.position(date: date)

            do {
                entries = try logStore.loadLogs(for: .init(position: position))

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

                allSubsystems = Array(tmpSubsystems).sorted()

                selectAllSubsystems()

                allCategories =  Array(tmpCategories).sorted()

                selectAllCategories()
            } catch  {

            }

//            isLoading = false
        }

        var filteredEntries: [OSLogEntryLog] {
            entries.filter { log in
                selectedSubsystems.contains(log.subsystem)
            }.filter { log in
                selectedCategories.contains(log.category)
            }.filter { log in
                if searchText.isEmpty {
                    return true
                } else {
                    return log.composedMessage.lowercased().contains(searchText.lowercased())
                }
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
