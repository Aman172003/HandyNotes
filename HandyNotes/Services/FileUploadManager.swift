import SwiftUI
import FirebaseStorage

struct FileUploadManager {
    static func processAndUploadFile(fileURL: URL?, uploadProgress: Binding<Double>, uploadSuccessful: Binding<Bool>, uploadedFileURL: Binding<String?>, errorMessage: Binding<String?>) async {
        guard let fileURL = fileURL else { return }

        let fileExtension = fileURL.pathExtension.lowercased()

        if fileExtension == "pdf" {
            await PDFProcessor.processPDF(fileURL, uploadProgress: uploadProgress, uploadSuccessful: uploadSuccessful, uploadedFileURL: uploadedFileURL, errorMessage: errorMessage)
        } else if ["jpg", "jpeg", "png", "tiff", "gif", "bmp"].contains(fileExtension) {
            await PDFProcessor.processImage(fileURL, uploadProgress: uploadProgress, uploadSuccessful: uploadSuccessful, uploadedFileURL: uploadedFileURL, errorMessage: errorMessage)
        } else {
            errorMessage.wrappedValue = "Unsupported file type"
        }
    }
}
