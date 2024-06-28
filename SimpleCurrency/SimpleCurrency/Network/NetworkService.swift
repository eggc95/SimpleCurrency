import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchExchangeRates(baseCurrency: String) -> AnyPublisher<ExchangeRates, Error>
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private init() {} 
    
    func fetchExchangeRates(baseCurrency: String) -> AnyPublisher<ExchangeRates, Error> {
        let urlString = "https://api.exchangerate-api.com/v4/latest/\(baseCurrency)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ExchangeRates.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
