import Foundation
import OSLog

struct OSLogStoreFilter {

    let position: OSLogPosition?

    let category: String?

    let subsystem: String?

    init(position: OSLogPosition? = nil, category: String? = nil, subsystem: String? = nil) {
        self.position = position
        self.category = category
        self.subsystem = subsystem
    }

}

extension OSLogStore {

    func getLogs(for filter: OSLogStoreFilter) async throws -> [OSLogEntryLog] {
        try await withCheckedThrowingContinuation { continuation in
            var query = [NSPredicate]()

            if let subsystem = filter.subsystem {
                query.append(NSPredicate(format: "subsystem = %@", subsystem))
            }

            if let category = filter.category {
                query.append(NSPredicate(format: "category = %@", category))
            }

            let match = query.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: query)

            do {
                let logs = try getEntries(at: filter.position, matching: match).compactMap {
                    $0 as? OSLogEntryLog
                }

                continuation.resume(returning: logs)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
