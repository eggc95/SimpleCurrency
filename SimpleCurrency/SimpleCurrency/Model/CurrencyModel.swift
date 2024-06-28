import Foundation

struct Currency: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let country: String
    let flagImage: String
}

struct ExchangeRates: Codable {
    let rates: [String: Double]
}
