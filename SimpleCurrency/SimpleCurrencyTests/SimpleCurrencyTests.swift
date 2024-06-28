import XCTest
import Combine
@testable import SimpleCurrency

class MockNetworkService: NetworkServiceProtocol {
    var exchangeRatesToReturn: ExchangeRates?
    var shouldReturnError = false
    
    func fetchExchangeRates(baseCurrency: String) -> AnyPublisher<ExchangeRates, Error> {
        if shouldReturnError {
            let error = NSError(domain: "MockNetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch exchange rates"])
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            guard let exchangeRates = exchangeRatesToReturn else {
                fatalError("Exchange rates not set in mock")
            }
            return Just(exchangeRates)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

class CurrencyViewModelTests: XCTestCase {
    
    var viewModel: CurrencyViewModel!
    var mockNetworkService: MockNetworkService!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = CurrencyViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.amountText, "")
        XCTAssertEqual(viewModel.selectedFromCurrency.code, "SGD")
        XCTAssertEqual(viewModel.selectedToCurrency.code, "USD")
        XCTAssertEqual(viewModel.convertedAmount, "0.00")
        XCTAssertEqual(viewModel.exchangeRateDescription, "Exchange rate: N/A")
    }
    
    func testConvert_ValidInput() {
        let exchangeRates = ExchangeRates(rates: ["USD": 1.2, "EUR": 1.5])
        let convertedAmount = viewModel.convert(amountText: "100", fromCurrency: "USD", toCurrency: "EUR", exchangeRates: exchangeRates)
        XCTAssertEqual(convertedAmount, "150.00")
    }
    
    func testConvert_InvalidInput() {
        let exchangeRates = ExchangeRates(rates: ["USD": 1.2])
        let convertedAmount = viewModel.convert(amountText: "abc", fromCurrency: "USD", toCurrency: "EUR", exchangeRates: exchangeRates)
        XCTAssertEqual(convertedAmount, "Invalid input")
    }
    
    func testSelectFromCurrency() {
        let newCurrency = Currency(code: "EUR", name: "Euro", country: "EU", flagImage: "eu_flag")
        viewModel.selectedFromCurrency = newCurrency
        
        XCTAssertEqual(viewModel.selectedFromCurrency.code, "EUR")
        viewModel.convertAndFetchRates()
        XCTAssertNotEqual(viewModel.convertedAmount, "0.00")
    }
    
    func testSelectToCurrency() {
        let newCurrency = Currency(code: "GBP", name: "Pound Sterling", country: "UK", flagImage: "gb_flag")
        viewModel.selectedToCurrency = newCurrency
        
        XCTAssertEqual(viewModel.selectedToCurrency.code, "GBP")
        viewModel.convertAndFetchRates()
        XCTAssertNotEqual(viewModel.convertedAmount, "0.00")
    }
    
    func testConvertZeroAmount() {
        let exchangeRates = ExchangeRates(rates: ["USD": 1.2, "EUR": 1.5])
        let convertedAmount = viewModel.convert(amountText: "0", fromCurrency: "USD", toCurrency: "EUR", exchangeRates: exchangeRates)
        XCTAssertEqual(convertedAmount, "0.00")
    }

    func testConvertLargeAmount() {
        let exchangeRates = ExchangeRates(rates: ["USD": 1.2, "EUR": 1.5])
        let convertedAmount = viewModel.convert(amountText: "1000000", fromCurrency: "USD", toCurrency: "EUR", exchangeRates: exchangeRates)
        XCTAssertEqual(convertedAmount, "1500000.00")
    }
    
    func testNetworkErrorHandling() {
        mockNetworkService.shouldReturnError = true
        
        let expectation = XCTestExpectation(description: "Network error handling")
        viewModel.$convertedAmount
            .dropFirst()
            .sink { convertedAmount in
                XCTAssertEqual(convertedAmount, "Failed to fetch exchange rates")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.convertAndFetchRates()
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCorrectConversionLogic() {
        let exchangeRates = ExchangeRates(rates: ["USD": 1.2, "EUR": 1.5, "JPY": 0.0091])
        
        let convertedAmountUSDToEUR = viewModel.convert(amountText: "100", fromCurrency: "USD", toCurrency: "EUR", exchangeRates: exchangeRates)
        XCTAssertEqual(convertedAmountUSDToEUR, "150.00")
        
        let convertedAmountUSDToJPY = viewModel.convert(amountText: "100", fromCurrency: "USD", toCurrency: "JPY", exchangeRates: exchangeRates)
        XCTAssertEqual(convertedAmountUSDToJPY, "910.00")
    }
    
    func testAmountTextChange() {
        let exchangeRates = ExchangeRates(rates: ["USD": 1.2, "EUR": 1.5])
        viewModel.amountText = "200"
        viewModel.selectedFromCurrency = Currency(code: "USD", name: "US Dollar", country: "USA", flagImage: "us_flag")
        viewModel.selectedToCurrency = Currency(code: "EUR", name: "Euro", country: "EU", flagImage: "eu_flag")
        
        viewModel.convertAndFetchRates()
        
        XCTAssertEqual(viewModel.convertedAmount, "300.00")
        XCTAssertEqual(viewModel.exchangeRateDescription, "1 USD to EUR: 1.5")
    }
}
