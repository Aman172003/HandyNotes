import PDFKit
import UIKit
import Vision
import SwiftUI

struct PDFProcessor {
    
    static func processPDF(_ url: URL, uploadProgress: Binding<Double>, uploadSuccessful: Binding<Bool>, uploadedFileURL: Binding<String?>, errorMessage: Binding<String?>) async {
        if let images = convertPDFToImages(pdfUrl: url) {
            do {
                let ocrTexts = try await OCRProcessor.performOCR(on: images)
                let qaText = try await QAGenerator.generateQuestionsAndAnswers(from: ocrTexts)
                await FileUploader.createAndUploadPDF(withText: qaText, uploadProgress: uploadProgress, uploadSuccessful: uploadSuccessful, uploadedFileURL: uploadedFileURL, errorMessage: errorMessage)
            } catch {
                errorMessage.wrappedValue = error.localizedDescription
            }
        }
    }
    
    static func processImage(_ url: URL, uploadProgress: Binding<Double>, uploadSuccessful: Binding<Bool>, uploadedFileURL: Binding<String?>, errorMessage: Binding<String?>) async {
        if let image = UIImage(contentsOfFile: url.path) {
            if let ocrText = await OCRProcessor.performOCR(on: image) {
                do {
                    let qaText = try await QAGenerator.generateQuestionsAndAnswers(from: ocrText)
                    await FileUploader.createAndUploadPDF(withText: qaText, uploadProgress: uploadProgress, uploadSuccessful: uploadSuccessful, uploadedFileURL: uploadedFileURL, errorMessage: errorMessage)
                } catch {
                    errorMessage.wrappedValue = error.localizedDescription
                }
            }
        }
    }

    private static func convertPDFToImages(pdfUrl: URL) -> [UIImage]? {
        guard let pdfDocument = PDFDocument(url: pdfUrl) else { return nil }
        
        var images: [UIImage] = []
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let pdfPage = pdfDocument.page(at: pageIndex) else { continue }
            let pdfPageRect = pdfPage.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pdfPageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pdfPageRect)
                ctx.cgContext.translateBy(x: 0.0, y: pdfPageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
            }
            images.append(img)
        }
        return images
    }
}
