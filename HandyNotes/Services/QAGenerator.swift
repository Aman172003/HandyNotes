import GoogleGenerativeAI
import Foundation

struct QAGenerator {
    static let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)

    static func generateQuestionsAndAnswers(from text: String) async throws -> String {
        let prompt = "Generate questions and answers from the following text:\n\n\(text)"
        
        do {
            let response = try await model.generateContent(prompt)
            return response.text ?? ""
        } catch {
            throw NSError(domain: "QAGenerationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to generate Q&A: \(error.localizedDescription)"])
        }
    }
}
