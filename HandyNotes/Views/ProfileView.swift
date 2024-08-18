//
//  ProfileView.swift
//  HandyNotes
//
//  Created by Aman on 17/08/24.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @State var isActive: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ZStack {
                        HStack {
                            Button {
                                
                            } label: {
                                Image("back")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text("Profile")
                                .font(.customfont(.regular, fontSize: 16))
                            Spacer()
                        }
                    }
                    .foregroundColor(.gray30)
                    .padding(.top, .topInsets)
                    
                    VStack(spacing: 4) {
                        Image("u1")
                            .resizable()
                            .frame(width: 70, height: 70)
                        Spacer().frame(height: 15)
                        Text("Abhinav Pandey")
                            .font(.customfont(.bold, fontSize: 20))
                            .foregroundColor(.white)
                        
                        Text("abhi@gmail.com")
                            .font(.customfont(.medium, fontSize: 12))
                            .accentColor(.gray30)
                        
                        Spacer().frame(height: 15)
                        
                        Button {
                            
                        } label: {
                            Text("Edit Profile")
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
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("General")
                            .font(.customfont(.semibold, fontSize: 14))
                            .padding(.top, 8)
                        
                        VStack {
                            IconItemRow(icon: "face_id", title: "Security", value: "FaceID")
                            IconItemSwitchRow(icon: "icloud", title: "iCloud Sync", value: $isActive)
                        }
                        .padding(.vertical, 10)
                        .background(Color.gray60.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray70, lineWidth: 1)
                        }
                        .cornerRadius(16)
                    }
                    .foregroundColor(.white)
                    
                    VStack {
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
                                    // Optionally, show an alert or message to the user if the sign-out fails.
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.grayC)
        }
        .background(Color.grayC) // Apply background to the entire view
        .ignoresSafeArea()
    }
}

#Preview {
    ProfileView(isLoggedIn: Binding.constant(false))
}
