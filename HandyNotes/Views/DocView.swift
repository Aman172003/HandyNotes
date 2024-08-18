//
//  DocView.swift
//  HandyNotes
//
//  Created by Aman on 17/08/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth

struct DocView: View {
    @State private var pdfURLs: [String] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if pdfURLs.isEmpty {
                    Text("No PDFs found.")
                        .padding()
                } else {
                    List(pdfURLs, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            HStack {
                                Text(url.lastPathComponent)  // Extract file name
                                    .font(.headline)
                                    .lineLimit(3)
                                    .truncationMode(.middle)
                                Spacer()
                                NavigationLink(destination: PDFView(url: urlString)) {
//                                    Text("View")
//                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Your PDFs", displayMode: .inline)
            .onAppear(perform: fetchPDFs)
        }
        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }

    // Function to fetch PDF URLs from Firebase Storage
    private func fetchPDFs() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            return
        }

        // Clear the existing URLs before fetching new ones
        pdfURLs.removeAll()

        let storageRef = Storage.storage().reference().child("users/\(userUID)")

        storageRef.listAll { (result, error) in
            if let error = error {
                errorMessage = "Failed to list PDFs: \(error.localizedDescription)"
                return
            }

            result?.items.forEach { item in
                item.downloadURL { url, error in
                    if let error = error {
                        errorMessage = "Failed to get download URL: \(error.localizedDescription)"
                    } else if let url = url {
                        DispatchQueue.main.async {
                            pdfURLs.append(url.absoluteString)
                        }
                    }
                }
            }
        }
    }

}

#Preview {
    DocView()
}

