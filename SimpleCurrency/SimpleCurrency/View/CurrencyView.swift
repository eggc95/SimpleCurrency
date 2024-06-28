import SwiftUI

struct CurrencyView: View {
    @ObservedObject private var viewModel = CurrencyViewModel()
    @State private var isFromCurrencyPickerPresented = false
    @State private var isToCurrencyPickerPresented = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Amount", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("From")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        currencyButton(selectedCurrency: $viewModel.selectedFromCurrency, isPickerPresented: $isFromCurrencyPickerPresented)
                    }
                    
                    
                    VStack(alignment: .leading) {
                        Text("To")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        currencyButton(selectedCurrency: $viewModel.selectedToCurrency, isPickerPresented: $isToCurrencyPickerPresented)
                    }
                }
                .padding()
                
                exchangeRateSection
                convertedAmountSection
                
                Spacer()
            }
            .navigationTitle("Currency Converter")
            .padding()
            .sheet(isPresented: $isFromCurrencyPickerPresented) {
                CurrencyPicker(currencies: viewModel.currencies, selectedCurrency: $viewModel.selectedFromCurrency, isPresented: $isFromCurrencyPickerPresented)
            }
            .sheet(isPresented: $isToCurrencyPickerPresented) {
                CurrencyPicker(currencies: viewModel.currencies, selectedCurrency: $viewModel.selectedToCurrency, isPresented: $isToCurrencyPickerPresented)
            }
        }
        .onAppear {
            viewModel.convertAndFetchRates()
        }
    }
    
    private func currencyButton(selectedCurrency: Binding<Currency>, isPickerPresented: Binding<Bool>) -> some View {
        Button(action: {
            isPickerPresented.wrappedValue = true
        }) {
            VStack {
                Image(selectedCurrency.wrappedValue.flagImage)
                    .resizable()
                    .frame(width: 30, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text(selectedCurrency.wrappedValue.code)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
    
    private var exchangeRateSection: some View {
        VStack(alignment: .center) {
            Text("Exchange Rate:")
                .font(.headline)
            Text(viewModel.exchangeRateDescription)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
    }
    
    private var convertedAmountSection: some View {
        VStack(alignment: .center) {
            Text("Converted Amount:")
                .font(.headline)
            Text(viewModel.convertedAmount)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
    }
}

struct CurrencyView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyView()
    }
}
