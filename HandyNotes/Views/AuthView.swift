import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    
    private let authService = AuthService()
    
    var body: some View {
        NavigationView{
            ZStack{
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    RoundTextField(title: "Email", text: $email, keyboardType: .emailAddress)
                    
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    
                    RoundTextField(title: "Passord", text: $password, isPassword: true)
                    
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    PrimaryButton(title: isSignUp ? "Sign Up" : "Log In") {
                                if isSignUp {
                                    authService.signUp(email: email, password: password, errorMessage: $errorMessage, isLoggedIn: $isLoggedIn)
                                } else {
                                    authService.logIn(email: email, password: password, errorMessage: $errorMessage, isLoggedIn: $isLoggedIn)
                                }
                            }
                    .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
                    Spacer()
                    Button(action: {
                        isSignUp.toggle()
                    }) {
                        Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                            .foregroundColor(.white)
                            .font(.customfont(.bold, fontSize: 16))
                    }
                    .padding()
                    
                    NavigationLink(destination: FileUploadView(), isActive: $isLoggedIn) {
                        EmptyView() // This will not display anything
                    }
                }
                .padding()
            }
        }
    }

    
}


#Preview {
    AuthView()
}
