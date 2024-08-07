import SwiftUI
import FirebaseStorage
import PDFKit
import Vision
import GoogleGenerativeAI

struct FileUploadView: View {
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    @State private var selectedFile: URL?
    @State private var uploadProgress: Double = 0.0
    @State private var showingFilePicker = false
    @State private var uploadSuccessful = false
    @State private var uploadedFileURL: String? // URL of the uploaded file as a String
    @State private var errorMessage: String? // State to store error messages

    var body: some View {
        NavigationView {
            VStack {
                Button("Select File") {
                    showingFilePicker = true
                }
                .padding()

                Button("Upload") {
                    Task {
                        await processAndUploadFile()
                    }
                }
                .padding()
                .disabled(selectedFile == nil)

                ProgressView(value: uploadProgress, total: 100.0)
                
                NavigationLink(destination: PDFView(url: uploadedFileURL), isActive: $uploadSuccessful) {
                    EmptyView()
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

    private func processAndUploadFile() async {
        guard let fileURL = selectedFile else { return }

        // Get the file extension in a case-insensitive manner
        let fileExtension = fileURL.pathExtension.lowercased()

        // Check file type and process accordingly
        if fileExtension == "pdf" {
            await processPDF(fileURL)
        } else if ["jpg", "jpeg", "png", "tiff", "gif", "bmp"].contains(fileExtension) {
            await processImage(fileURL)
        } else {
            errorMessage = "Unsupported file type"
        }
    }

    private func processPDF(_ url: URL) async {
        // Convert PDF pages to images and perform OCR on each page
        if let images = convertPDFToImages(pdfUrl: url) {
            do {
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
                let ocrText = ocrTexts.joined(separator: "\n")
                let qaText = try await generateQuestionsAndAnswers(from: ocrText)
                createAndUploadPDF(withText: qaText)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func processImage(_ url: URL) async {
        if let image = UIImage(contentsOfFile: url.path) {
            if let ocrText = await performOCR(on: image) {
                do {
                    let qaText = try await generateQuestionsAndAnswers(from: ocrText)
                    createAndUploadPDF(withText: qaText)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func performOCR(on image: UIImage) async -> String? {
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

    private func generateQuestionsAndAnswers(from text: String) async throws -> String {
        let prompt = "Generate questions and answers from the following text:\n\n\(text)"
        
        do {
            let response = try await model.generateContent(prompt)
            return response.text ?? ""
        } catch {
            throw NSError(domain: "QAGenerationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to generate Q&A: \(error.localizedDescription)"])
        }
    }

    private func createAndUploadPDF(withText text: String) {
        guard let pdfData = createPDF(withText: text) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        
        do {
            try pdfData.write(to: tempURL)
            uploadFile(tempURL)
        } catch {
            errorMessage = "Failed to write PDF file: \(error.localizedDescription)"
        }
    }

    private func uploadFile(_ fileURL: URL) {
        let storageRef = Storage.storage().reference().child("files/\(fileURL.lastPathComponent)")
        let uploadTask = storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                errorMessage = "Upload failed: \(error.localizedDescription)"
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        errorMessage = "Failed to get download URL: \(error.localizedDescription)"
                    } else if let url = url {
                        self.uploadedFileURL = url.absoluteString
                        self.uploadSuccessful = true
                    }
                }
            }
        }

        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                uploadProgress = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            }
        }
    }

    private func convertPDFToImages(pdfUrl: URL) -> [UIImage]? {
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

    private func createPDF(withText text: String) -> Data? {
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
}

#Preview {
    FileUploadView()
}
