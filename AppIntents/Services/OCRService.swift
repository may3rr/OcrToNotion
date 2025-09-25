import Foundation
import Vision

enum OCRServiceError: Error {
    case imageConversionFailed
    case recognitionFailed
}

struct OCRService {
    func recognizeText(from imageData: Data) async throws -> String {
        guard let image = CIImage(data: imageData) else {
            throw OCRServiceError.imageConversionFailed
        }

        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = ["zh-Hans", "en-US"]
        request.usesLanguageCorrection = true

        try handler.perform([request])
        guard let observations = request.results else {
            throw OCRServiceError.recognitionFailed
        }

        return observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }
}
