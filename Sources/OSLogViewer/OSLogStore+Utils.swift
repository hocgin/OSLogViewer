import Foundation
import OSLog

extension OSLogEntryLog : Identifiable {

}

struct OSLogStoreFilter {

    let position: OSLogPosition

    let category: String?

    let subsystem: String?

    init(position: OSLogPosition, category: String? = nil, subsystem: String? = nil) {
        self.position = position
        self.category = category
        self.subsystem = subsystem
    }

}

extension OSLogStore {

    func loadLogs(for filter: OSLogStoreFilter) throws -> [OSLogEntryLog] {

        var query = [NSPredicate]()

        if let subsystem = filter.subsystem {
            query.append(NSPredicate(format: "subsystem = %@", subsystem))
        }

        if let category = filter.category {
            query.append(NSPredicate(format: "category = %@", category))
        }

        let match = query.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: query)

        return try getEntries(at: filter.position, matching: match).compactMap {
            $0 as? OSLogEntryLog
        }
    }

}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
