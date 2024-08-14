import SwiftUI
import FirebaseStorage
import PDFKit

struct FileUploadView: View {
    @State private var selectedFile: URL?
    @State private var uploadProgress: Double = 0.0
    @State private var showingFilePicker = false
    @State private var uploadSuccessful = false
    @State private var uploadedFileURL: String?
    @State private var errorMessage: String?
    @State private var isUploading: Bool = false

    var body: some View {
        NavigationView {
            ZStack{
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack {
                    Group {
                        if let selectedFile = selectedFile {
                            Text("Selected File: \(selectedFile.lastPathComponent)")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Text("No file selected")
                                .font(.headline)
                                .foregroundColor(.clear) // Invisible but takes up space
                        }
                    }
                    .padding(.bottom, 20)
                    
                    if !isUploading {
                        SecondaryButton(title: "Select File") {
                            showingFilePicker = true
                        }
                        .padding(.bottom, 40)
                        
                        PrimaryButton(title: "Upload") {
                            isUploading = true
                            Task {
                                await FileUploadManager.processAndUploadFile(
                                    fileURL: selectedFile,
                                    uploadProgress: $uploadProgress,
                                    uploadSuccessful: $uploadSuccessful,
                                    uploadedFileURL: $uploadedFileURL,
                                    errorMessage: $errorMessage
                                )
                            }
                        }
                        .disabled(selectedFile == nil)
                    } else {
                        CustomLoader()
                            .padding()
                    }
                    
                    if uploadSuccessful {
                        NavigationLink(destination: PDFView(url: uploadedFileURL), isActive: $uploadSuccessful) {
                            EmptyView()
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
                .sheet(isPresented: $showingFilePicker) {
                    FilePicker(allowedTypes: ["public.item"], onPicked: { url in
                        self.selectedFile = url
                    }, onCancel: {
                        self.selectedFile = nil
                        print("File selection was canceled.")
                    })
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

#Preview {
    FileUploadView()
}
