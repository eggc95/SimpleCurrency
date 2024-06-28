import Foundation
import Combine

class CurrencyViewModel: ObservableObject {
    @Published var amountText: String = "1"
    @Published var selectedFromCurrency: Currency = Currency(code: "SGD", name: "Singapore Dollar", country: "Singapore", flagImage: "sg_flag") {
        didSet {
            convertAndFetchRates()
        }
    }
    @Published var selectedToCurrency: Currency = Currency(code: "USD", name: "United States Dollar", country: "United States", flagImage: "us_flag") {
        didSet {
            convertAndFetchRates()
        }
    }
    @Published private(set) var convertedAmount: String = "0.00"
    @Published private(set) var exchangeRateDescription: String = ""
    
    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var exchangeRates: ExchangeRates? 
    
    let currencies: [Currency] = [
        Currency(code: "USD", name: "United States Dollar", country: "United States", flagImage: "us_flag"),
        Currency(code: "SGD", name: "Singapore Dollar", country: "Singapore", flagImage: "sg_flag"),
        Currency(code: "MYR", name: "Malaysian Ringgit", country: "Malaysia", flagImage: "my_flag"),
        Currency(code: "EUR", name: "Euro", country: "European Union", flagImage: "eu_flag"),
        Currency(code: "JPY", name: "Japanese Yen", country: "Japan", flagImage: "jp_flag"),
        Currency(code: "GBP", name: "Pound Sterling", country: "United Kingdom", flagImage: "gb_flag"),
        Currency(code: "CNY", name: "Chinese Renminbi", country: "China", flagImage: "cn_flag")
    ]
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
        setupBindings()
    }
    
    private func setupBindings() {
        $amountText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.convertAndFetchRates()
            }
            .store(in: &cancellables)
    }
   
    func convertAndFetchRates() {
        networkService.fetchExchangeRates(baseCurrency: selectedFromCurrency.code)
            .map { [weak self] exchangeRates -> String in
                guard let self = self else { return "Invalid input" }
                self.exchangeRates = exchangeRates
                return self.convert(amountText: self.amountText, fromCurrency: self.selectedFromCurrency.code, toCurrency: self.selectedToCurrency.code, exchangeRates: exchangeRates)
            }
            .replaceError(with: "Failed to fetch exchange rates")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.convertedAmount = value
                self?.updateExchangeRateDescription()
            }
            .store(in: &cancellables)
    }
    
    func convert(amountText: String, fromCurrency: String, toCurrency: String, exchangeRates: ExchangeRates) -> String {
        guard let amount = Double(amountText), let rate = exchangeRates.rates[toCurrency] else {
            return "Invalid input"
        }
        
        let convertedAmount = amount * rate
        return String(format: "%.2f", convertedAmount)
    }
    
    func updateExchangeRateDescription() {
        let fromCurrencyCode = selectedFromCurrency.code
        let toCurrencyCode = selectedToCurrency.code
        
        guard let exchangeRates = exchangeRates else {
            exchangeRateDescription = "Exchange rate: Not available"
            return
        }
        
        if let rate = exchangeRates.rates[toCurrencyCode] {
            exchangeRateDescription = "1 \(fromCurrencyCode) to \(toCurrencyCode): \(rate)"
        } else {
            exchangeRateDescription = "Exchange rate: Not available"
        }
    }
}
