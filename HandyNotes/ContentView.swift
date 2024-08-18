import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = Auth.auth().currentUser != nil
    @State var selectedTab = 0
    
    var body: some View {
        Group {
            if isLoggedIn {
                TabView(selection: $selectedTab) {
                    FileUploadView()
                        .toolbarBackground(.visible, for: .tabBar)
                        .tabItem {
                            Label("Upload", systemImage: "square.and.arrow.up")
                        }
                        .tag(0)
                    
                    DocView()
                        .toolbarBackground(.visible, for: .tabBar)
                        .tabItem {
                            Label("Documents", systemImage: "doc.text")
                        }
                        .tag(1)
                    
                    ProfileView(isLoggedIn: $isLoggedIn)
                        .toolbarBackground(.visible, for: .tabBar)
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag(2)
                }
                .accentColor(Color(red: 0.933, green: 0.506, blue: 0.427))
                .preferredColorScheme(.dark)
            } else {
                AuthView()
            }
        }
        .onAppear {
            // Listen for authentication state changes
            Auth.auth().addStateDidChangeListener { auth, user in
                isLoggedIn = user != nil
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
