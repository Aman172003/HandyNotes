import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var isLoggedIn = false

    var body: some View {
        NavigationView{
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    isSignUp ? signUp() : logIn()
                }) {
                    Text(isSignUp ? "Sign Up" : "Log In")
                }
                .padding()
                .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                
                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                }
                .padding()
                
                NavigationLink(destination: FileUploadView(), isActive: $isLoggedIn) {
                                    EmptyView() // This will not display anything
                                }
            }
            .padding()
        }
    }

    private func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true // Set to true on successful login
            }
        }
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true // Set to true on successful login
            }
        }
    }
}


#Preview {
    AuthView()
}
