import SwiftUI
import OSLog

extension OSLogEntryLog {
    var backgroundColor: Color {
        switch level {
        case .error: return .yellow.opacity(0.1)
        case .fault: return .red.opacity(0.1)
        default: return .white
        }
    }
}

struct OSLogEntryRow: View {

    let entry: OSLogEntryLog

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.composedMessage)
                .textSelection(.enabled)
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
//        .contextMenu {
//            Button {
////                viewModel.selectedSubsystems = [name]
//            } label: {
//                Label("Only select", systemImage: "heart")
//            }
//
//            Button {
////                viewModel.selectAllSubsystems()
//            } label: {
//                Label("Select All", systemImage: "heart")
//            }
//        }
    }
}

//#Preview {
//    SwiftUIView()
//}
