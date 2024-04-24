import SwiftUI

public struct OSLogViewer: View {

    public init() { }
    
    public var body: some View {
        NavigationView {
            OSLogList()
        }
    }
}

#Preview {
    OSLogViewer()
}
