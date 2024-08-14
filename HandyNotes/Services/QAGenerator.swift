import GoogleGenerativeAI
import Foundation

struct QAGenerator {
    static let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)

    static func generateQuestionsAndAnswers(from text: String) async throws -> String {
        let chunkSize = 2000  // You can adjust this size based on your needs
        let chunks = text.chunked(into: chunkSize)
        var qaText = ""
        
        for chunk in chunks {
            let prompt = """
            Please generate a list of questions and answers based on the following text:
            
            \(chunk)
            
            Format the output as follows:
            Question: [Question Text]
            Answer: [Answer Text]
            
            Ensure that the questions and answers are clearly separated and that there are no extra characters or formatting issues.
            """
            
            do {
                let response = try await model.generateContent(prompt)
                if let generatedText = response.text {
                    let cleanedText = cleanGeneratedText(generatedText)
                    print(cleanedText)
                    qaText += cleanedText + "\n\n"
                }
            } catch {
                throw NSError(domain: "QAGenerationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to generate Q&A: \(error.localizedDescription)"])
            }
        }
        
        return qaText
    }

    private static func cleanGeneratedText(_ text: String) -> String {
        // Remove unwanted characters or patterns from the generated text
        var cleanedText = text
        cleanedText = cleanedText.replacingOccurrences(of: "\\*", with: "", options: .regularExpression)
        // Add more cleaning rules as needed
        return cleanedText
    }
}

extension String {
    func chunked(into size: Int) -> [String] {
        var chunks: [String] = []
        var startIndex = self.startIndex
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            let chunk = String(self[startIndex..<endIndex])
            chunks.append(chunk)
            startIndex = endIndex
        }
        return chunks
    }
}
