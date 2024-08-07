import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = Auth.auth().currentUser != nil

    var body: some View {
        Group {
            if isLoggedIn {
                FileUploadView()
            } else {
                AuthView()
            }
        }
        .onChange(of: Auth.auth().currentUser) { _ in
            isLoggedIn = Auth.auth().currentUser != nil
        }
    }
}

#Preview {
    ContentView()
}
