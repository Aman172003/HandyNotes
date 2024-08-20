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
    @State private var selectedURL: String?
    @State private var showPDFView: Bool = false

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
                                Menu {
                                    Button(action: {
                                        // Handle view action
                                        selectedURL = urlString
                                        showPDFView = true
                                    }) {
                                        Label("View", systemImage: "eye")
                                    }
                                    Button(action: {
                                        // Handle delete action
                                        deletePDF(at: urlString)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .imageScale(.large)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Your PDFs", displayMode: .inline)
            .onAppear(perform: fetchPDFs)
            .background(
                NavigationLink(
                    destination: PDFView(url: selectedURL ?? ""),
                    isActive: $showPDFView
                ) {
                    EmptyView()
                }
            )
        }
        .preferredColorScheme(.dark)
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

    // Function to delete a PDF
    private func deletePDF(at urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let storageRef = Storage.storage().reference(forURL: urlString)

        storageRef.delete { error in
            if let error = error {
                errorMessage = "Failed to delete PDF: \(error.localizedDescription)"
            } else {
                // Remove the URL from the list
                DispatchQueue.main.async {
                    pdfURLs.removeAll { $0 == urlString }
                }
            }
        }
    }
}

#Preview {
    DocView()
}




