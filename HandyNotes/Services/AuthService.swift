//
//  AuthService.swift
//  HandyNotes
//
//  Created by Aman on 09/08/24.
//

import SwiftUI
import FirebaseAuth

struct AuthService {
    
    // Log in method: no userName required here
    func logIn(email: String, password: String, errorMessage: Binding<String>, isLoggedIn: Binding<Bool>) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage.wrappedValue = error.localizedDescription
            } else {
                isLoggedIn.wrappedValue = true
            }
        }
    }
    
    // Sign up method: userName added and saved to the user's profile
    func signUp(email: String, password: String, userName: String, errorMessage: Binding<String>, isLoggedIn: Binding<Bool>) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage.wrappedValue = error.localizedDescription
            } else {
                // Set the user's display name to the provided userName
                if let user = result?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = userName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            errorMessage.wrappedValue = "Failed to set display name: \(error.localizedDescription)"
                        } else {
                            // Successfully signed up and set display name
                            isLoggedIn.wrappedValue = true
                        }
                    }
                }
            }
        }
    }
}


