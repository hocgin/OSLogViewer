import SwiftUI
import OSLog
import UIKit

extension OSLogEntryLog {
    var backgroundColor: Color {
        switch level {
        case .error: return .yellow.opacity(0.1)
        case .fault: return .red.opacity(0.1)
        default: return .init(uiColor: .systemBackground)
        }
    }
}

struct OSLogEntryRow: View {

    let entry: OSLogEntryLog

    @EnvironmentObject
    private var viewModel: OSLogList.ViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.composedMessage)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text(entry.date.formatted())
                Spacer()
                Text(entry.subsystem)
                Text(entry.category)
            }
            .foregroundColor(Color(uiColor: .secondaryLabel))
            .font(.caption)
        }
        .listRowBackground(entry.backgroundColor)
        .contextMenu {
            Button("Copy") {
                UIPasteboard.general.string = entry.composedMessage
            }

            Button("Only Select \(entry.subsystem)") {
                viewModel.selectedSubsystems = [entry.subsystem]
            }

            Button("Only Select \(entry.category)") {
                viewModel.selectedCategories = [entry.category]
            }
        }
    }
}

//#Preview {
//    SwiftUIView()
//}
