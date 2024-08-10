import UIKit
import Vision

struct OCRProcessor {
    
    static func performOCR(on images: [UIImage]) async throws -> String {
        let ocrTexts = try await withThrowingTaskGroup(of: String?.self) { group -> [String] in
            for image in images {
                group.addTask {
                    return await performOCR(on: image)
                }
            }
            return try await group.reduce(into: [String]()) { result, ocrText in
                if let ocrText = ocrText {
                    result.append(ocrText)
                }
            }
        }
        return ocrTexts.joined(separator: "\n")
    }

    static func performOCR(on image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { (request, error) in
                if let error = error {
                    print("OCR failed: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }

                let results = request.results as? [VNRecognizedTextObservation]
                let recognizedStrings = results?.compactMap { observation -> String? in
                    guard let topCandidate = observation.topCandidates(1).first else { return nil }
                    return topCandidate.string
                }
                continuation.resume(returning: recognizedStrings?.joined(separator: "\n"))
            }
            request.recognitionLevel = .accurate

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error.localizedDescription)")
                continuation.resume(returning: nil)
            }
        }
    }
}
