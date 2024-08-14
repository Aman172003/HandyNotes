import PDFKit
import UIKit
import Vision
import SwiftUI

struct PDFProcessor {
    static func processPDF(_ url: URL, uploadProgress: Binding<Double>, uploadSuccessful: Binding<Bool>, uploadedFileURL: Binding<String?>, errorMessage: Binding<String?>) async {
        if let images = convertPDFToImages(pdfUrl: url) {
            do {
                await MainActor.run { uploadProgress.wrappedValue = 0.1 }
                
                // Perform OCR
                let ocrTexts = try await OCRProcessor.performOCR(on: images)
                
                await MainActor.run { uploadProgress.wrappedValue = 0.5 }
                
                // Generate Q&A text in chunks
                let qaText = try await QAGenerator.generateQuestionsAndAnswers(from: ocrTexts)
                
                await MainActor.run { uploadProgress.wrappedValue = 0.7 }
                
                // Upload generated PDF
                await FileUploader.createAndUploadPDF(withText: qaText, uploadProgress: uploadProgress, uploadSuccessful: uploadSuccessful, uploadedFileURL: uploadedFileURL, errorMessage: errorMessage)
                
            } catch {
                errorMessage.wrappedValue = error.localizedDescription
            }
        } else {
            errorMessage.wrappedValue = "Failed to convert PDF to images."
        }
    }


    
    static func processImage(_ url: URL, uploadProgress: Binding<Double>, uploadSuccessful: Binding<Bool>, uploadedFileURL: Binding<String?>, errorMessage: Binding<String?>) async {
        if let image = UIImage(contentsOfFile: url.path) {
            do {
                let ocrText = try await OCRProcessor.performOCR(on: image)
                let qaText = try await QAGenerator.generateQuestionsAndAnswers(from: ocrText)
                await FileUploader.createAndUploadPDF(withText: qaText, uploadProgress: uploadProgress, uploadSuccessful: uploadSuccessful, uploadedFileURL: uploadedFileURL, errorMessage: errorMessage)
            } catch {
                errorMessage.wrappedValue = error.localizedDescription
            }
        } else {
            errorMessage.wrappedValue = "Failed to load image from the given URL."
        }
    }


    private static func convertPDFToImages(pdfUrl: URL) -> [UIImage]? {
        guard let pdfDocument = PDFDocument(url: pdfUrl) else {
            print("Failed to load PDF document from URL: \(pdfUrl)")
            return nil
        }

        var images: [UIImage] = []
        let maxSize: CGFloat = 2000.0  // Maximum dimension size for scaling

        for pageIndex in 0..<pdfDocument.pageCount {
            guard let pdfPage = pdfDocument.page(at: pageIndex) else {
                print("Failed to retrieve PDF page at index: \(pageIndex)")
                continue
            }

            let pdfPageRect = pdfPage.bounds(for: .mediaBox)

            // Validate the page size
            guard !pdfPageRect.isEmpty, pdfPageRect.width > 0, pdfPageRect.height > 0 else {
                print("Invalid page size for page at index \(pageIndex): \(pdfPageRect)")
                continue
            }

            // Determine scale factor to ensure that the image dimensions are within reasonable bounds
            let widthScale = maxSize / pdfPageRect.width
            let heightScale = maxSize / pdfPageRect.height
            let scaleFactor = min(widthScale, heightScale) // Maintain aspect ratio
            let scaledSize = CGSize(width: pdfPageRect.width * scaleFactor, height: pdfPageRect.height * scaleFactor)

            // Render the page to an image
            let renderer = UIGraphicsImageRenderer(size: scaledSize)
            let img = renderer.image { ctx in
                UIColor.white.set() // Background color (optional)
                ctx.fill(CGRect(origin: .zero, size: scaledSize))
                ctx.cgContext.translateBy(x: 0.0, y: scaledSize.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                ctx.cgContext.scaleBy(x: scaleFactor, y: scaleFactor)
                pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
            }

            images.append(img)
            print("Successfully converted page at index \(pageIndex) to image.")
        }

        if images.isEmpty {
            print("No images were created from the PDF.")
        }

        return images
    }
}
