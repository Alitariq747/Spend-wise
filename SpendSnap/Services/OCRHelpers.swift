//
//  OCRHelpers.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 06/10/2025.
//

import Foundation
import Vision
import VisionKit

func recognizeText(in image: UIImage, roiBottomFraction: CGFloat = 0.4,
                   completion: @escaping ([String]) -> Void) {
    guard let cg = image.cgImage else { completion([]); return }

    let req = VNRecognizeTextRequest { r, _ in
        let obs = (r.results as? [VNRecognizedTextObservation]) ?? []
        completion(obs.compactMap { $0.topCandidates(1).first?.string })
    }
    req.recognitionLevel = .accurate
    req.usesLanguageCorrection = true
    req.recognitionLanguages = ["en_US"]       // adjust if needed
    req.customWords = ["TOTAL","SUBTOTAL","GRAND","BALANCE","AMOUNT"]

    // Region of Interest: bottom X% (Vision ROI uses normalized coords; origin is bottom-left)
    req.regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: roiBottomFraction)

    let handler = VNImageRequestHandler(cgImage: cg, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
        do { try handler.perform([req]) } catch { completion([]) }
    }
}

func detectDate(in lines: [String]) -> Date? {
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
    for line in lines {
        let range = NSRange(line.startIndex..., in: line)
        if let m = detector?.firstMatch(in: line, options: [], range: range),
           let d = m.date { return d }
    }
    return nil
}

private let amountRx = try! NSRegularExpression(
  pattern: #"(?:PKR|Rs\.?|\$)?\s*([0-9]{1,3}(?:,[0-9]{3})*|[0-9]+)(?:\.[0-9]{2})?"#,
  options: [.caseInsensitive]
)

func findTotal(in lines: [String]) -> Decimal? {
    struct Cand { let value: Decimal; let weight: Int }
    var cands: [Cand] = []

    for line in lines {
        // downweight line-item-ish patterns
        let isLineItem = line.range(of: #"(@|qty|x\s*\d)"#, options: [.regularExpression, .caseInsensitive]) != nil
        let hasTotalWord = line.range(of: "total|grand|amount|balance",
                                      options: [.regularExpression, .caseInsensitive]) != nil
        let w = (hasTotalWord ? 3 : 1) - (isLineItem ? 2 : 0)

        let ns = line as NSString
        let range = NSRange(location: 0, length: ns.length)
        amountRx.enumerateMatches(in: line, options: [], range: range) { m, _, _ in
            guard let m, m.range(at: 1).location != NSNotFound else { return }
            let raw = ns.substring(with: m.range(at: 1)).replacingOccurrences(of: ",", with: "")
            if let dec = Decimal(string: raw) { cands.append(.init(value: dec, weight: w)) }
        }
    }

    guard !cands.isEmpty else { return nil }
    // prefer higher weight; then larger amount
    return cands.max { (a, b) -> Bool in
        if a.weight != b.weight { return a.weight < b.weight }
        return a.value < b.value
    }?.value
}


