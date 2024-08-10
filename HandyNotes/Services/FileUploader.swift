import FirebaseStorage
import PDFKit
import SwiftUI

struct FileUploader {
    
    static func createAndUploadPDF(withText text: String, uploadProgress: Binding<Double>, uploadSuccessful: Binding<Bool>, uploadedFileURL: Binding<String?>, errorMessage: Binding<String?>) async {
        guard let pdfData = createPDF(withText: text) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        
        do {
            try pdfData.write(to: tempURL)
            uploadFile(tempURL, uploadProgress: uploadProgress, uploadSuccessful: uploadSuccessful, uploadedFileURL: uploadedFileURL, errorMessage: errorMessage)
        } catch {
            errorMessage.wrappedValue = "Failed to write PDF file: \(error.localizedDescription)"
        }
    }

    private static func createPDF(withText text: String) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Your App Name",
            kCGPDFContextAuthor: "Your Name",
            kCGPDFContextTitle: "Generated PDF"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()
            let textFont = UIFont.systemFont(ofSize: 12.0)
            let textAttributes: [NSAttributedString.Key: Any] = [ .font: textFont ]
            let attributedText = NSAttributedString(string: text, attributes: textAttributes)
            attributedText.draw(in: CGRect(x: 20, y: 20, width: pageRect.width - 40, height: pageRect.height - 40))
        }

        return data
    }

    private static func uploadFile(_ fileURL: URL, uploadProgress: Binding<Double>, uploadSuccessful: Binding<Bool>, uploadedFileURL: Binding<String?>, errorMessage: Binding<String?>) {
        let storageRef = Storage.storage().reference().child("files/\(fileURL.lastPathComponent)")
        let uploadTask = storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                errorMessage.wrappedValue = "Upload failed: \(error.localizedDescription)"
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        errorMessage.wrappedValue = "Failed to get download URL: \(error.localizedDescription)"
                    } else if let url = url {
                        uploadedFileURL.wrappedValue = url.absoluteString
                        uploadSuccessful.wrappedValue = true
                    }
                }
            }
        }

        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                uploadProgress.wrappedValue = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            }
        }
    }
}
