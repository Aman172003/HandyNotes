import SwiftUI
import PDFKit
import UIKit
import MobileCoreServices

struct PDFView: View {
    let url: String?
    @State private var showDocumentPicker = false
    @State private var downloadedURL: URL?

    var body: some View {
        VStack {
            if let url = url, let pdfURL = URL(string: url) {
                PDFKitView(url: pdfURL)
                    .edgesIgnoringSafeArea(.all)

                Button("Download PDF") {
                    showDocumentPicker = true
                }
                .foregroundColor(.white)
                .font(.customfont(.medium, fontSize: 16))
                .padding()
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker { url in
                        if let url = url {
                            downloadedURL = url
                            downloadPDF(from: pdfURL, to: url)
                        }
                    }
                }
            } else {
                Text("Failed to load PDF")
                    .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color.grayC)
    }

    private func downloadPDF(from url: URL, to destinationURL: URL) {
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Download failed: \(error.localizedDescription)")
                    return
                }

                guard let location = location else {
                    print("Download location is nil.")
                    return
                }

                do {
                    // Move the downloaded file to the destination URL
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    print("PDF downloaded to: \(destinationURL.path)")
                } catch {
                    print("Failed to save PDF: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume() // Start the download task
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFKit.PDFView {
        let pdfView = PDFKit.PDFView()
        pdfView.autoScales = true
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        return pdfView
    }

    func updateUIView(_ pdfView: PDFKit.PDFView, context: Context) {
        // You can update the view here if needed
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var completionHandler: (URL?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Initialize the picker for exporting files
        let picker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .exportToService)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.completionHandler(url)
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.completionHandler(nil)
        }
    }
}


#Preview {
    PDFView(url: "https://example.com/sample.pdf") // Replace with a valid URL for previewing
}
