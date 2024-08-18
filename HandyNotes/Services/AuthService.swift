//
//  AuthService.swift
//  HandyNotes
//
//  Created by Aman on 09/08/24.
//

import SwiftUI
import FirebaseAuth

struct AuthService {
    func logIn(email: String, password: String, errorMessage: Binding<String>, isLoggedIn: Binding<Bool>) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage.wrappedValue = error.localizedDescription
            } else {
                isLoggedIn.wrappedValue = true
            }
        }
    }

    func signUp(email: String, password: String, errorMessage: Binding<String>, isLoggedIn: Binding<Bool>) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage.wrappedValue = error.localizedDescription
            } else {
                isLoggedIn.wrappedValue = true
            }
        }
    }
}

