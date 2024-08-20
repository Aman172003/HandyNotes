import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @State var isActive: Bool = false
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var showEditFields: Bool = false
    @State private var newUserName: String = ""
    @State private var newPassword: String = ""

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 4) {
                    Image("u1")
                        .resizable()
                        .frame(width: 70, height: 70)
                    Spacer().frame(height: 15)
                    Text(userName.isEmpty ? "Unknown" : userName)
                        .font(.customfont(.bold, fontSize: 20))
                        .foregroundColor(.white)
                                            
                    Text(userEmail.isEmpty ? "No Email" : userEmail)
                        .font(.customfont(.medium, fontSize: 12))
                        .accentColor(.gray30)
                    
                    Spacer().frame(height: 15)
                    
                    Button {
                        withAnimation {
                            showEditFields.toggle()
                        }
                    } label: {
                        Text(showEditFields ? "Close" : "Edit Profile")
                            .font(.customfont(.semibold, fontSize: 12))
                    }
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.gray60.opacity(0.2))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray70, lineWidth: 1)
                    }
                    .cornerRadius(12)
                    
                    if showEditFields {
                        VStack(spacing: 10) {
                            RoundTextField(title: "Name", text: $newUserName)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 15)
                            
                            RoundTextField(title: "Email", text: $userEmail)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 15)
                                .disabled(true)
                            
                            RoundTextField(title: "New Password", text: $newPassword, isPassword: true)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 15)
                            
                            SecondaryButton(title: "Save Changes") {
                                updateProfile()
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.top, .topInsets)
                .padding(.horizontal, 20)
            }
            .background(Color.grayC)
            
            // Delete Account button at the bottom of the view
            if(!showEditFields) {
                SecondaryButton(title: "Delete Account") {
                    deleteAccount()
                }
                .padding(.bottom, 15)
            }
            
            // Signout button at the bottom of the view
            PrimaryButton(title: "Signout") {
                Task {
                    do {
                        try Auth.auth().signOut()
                        print("User signed out successfully.")
                        
                        // Update the app's state to indicate the user is signed out
                        DispatchQueue.main.async {
                            isLoggedIn = false
                        }
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color.grayC)
        .ignoresSafeArea()
        .onAppear {
            // Fetch the current user
            if let user = Auth.auth().currentUser {
                self.userName = user.displayName ?? "Unknown"
                self.userEmail = user.email ?? "No Email"
                self.newUserName = self.userName
            }
        }
    }
    
    private func updateProfile() {
        // Update the user's name
        if !newUserName.isEmpty && newUserName != userName {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = newUserName
            changeRequest?.commitChanges { error in
                if let error = error {
                    print("Error updating display name: \(error.localizedDescription)")
                } else {
                    self.userName = newUserName
                    print("Display name updated successfully.")
                }
            }
        }
        
        // Update the user's password
        if !newPassword.isEmpty {
            guard let email = Auth.auth().currentUser?.email else { return }
            
            // Prompt for current password
            let alert = UIAlertController(title: "Re-authentication Required", message: "Please enter your current password to continue.", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Current Password"
                textField.isSecureTextEntry = true
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                let password = alert.textFields?.first?.text ?? ""
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                
                // Re-authenticate
                Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
                    if let error = error {
                        print("Error re-authenticating: \(error.localizedDescription)")
                        return
                    }
                    
                    // Update password
                    Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                        if let error = error {
                            print("Error updating password: \(error.localizedDescription)")
                        } else {
                            print("Password updated successfully.")
                        }
                    }
                }
            }))
            
            // Show the alert
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        // Hide the edit fields after saving changes
        withAnimation {
            showEditFields = false
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Prompt for current password
        let alert = UIAlertController(title: "Re-authentication Required", message: "Please enter your current password to continue.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Current Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            let password = alert.textFields?.first?.text ?? ""
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
            
            // Re-authenticate
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    print("Error re-authenticating: \(error.localizedDescription)")
                    return
                }
                
                // Delete the account
                user.delete { error in
                    if let error = error {
                        print("Error deleting account: \(error.localizedDescription)")
                    } else {
                        print("Account deleted successfully.")
                        // Sign out and update the app's state to indicate the user is signed out
                        DispatchQueue.main.async {
                            isLoggedIn = false
                        }
                    }
                }
            }
        }))
        
        // Show the alert
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

#Preview {
    ProfileView(isLoggedIn: Binding.constant(false))
}
