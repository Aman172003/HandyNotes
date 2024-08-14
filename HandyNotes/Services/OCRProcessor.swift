import UIKit
import Vision

struct OCRProcessor {
    
    static func performOCR(on images: [UIImage]) async throws -> String {
        var ocrTexts = [String]()
        
        for (index, image) in images.enumerated() {
            do {
                let text = try await performOCR(on: image)
                print("OCR done for page: \(index)")
                ocrTexts.append(text)
            } catch {
                print("Error processing image at index \(index): \(error)")
                // Handle the error, skip to the next image
                continue
            }
        }
        
        return ocrTexts.joined(separator: "\n")
    }

    static func performOCR(on image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { throw NSError(domain: "InvalidImage", code: 0, userInfo: nil) }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { (request, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let results = request.results as? [VNRecognizedTextObservation]
                let recognizedStrings = results?.compactMap { observation -> String? in
                    observation.topCandidates(1).first?.string
                }
                
                let recognizedText = recognizedStrings?.joined(separator: "\n") ?? ""
                continuation.resume(returning: recognizedText)
            }
            request.recognitionLevel = .accurate

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
