import SwiftUI

struct CurrencyPicker: View {
    let currencies: [Currency]
    @Binding var selectedCurrency: Currency
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(currencies) { currency in
                Button(action: {
                    selectedCurrency = currency
                    isPresented = false
                }) {
                    HStack {
                        Image(currency.flagImage)
                            .resizable()
                            .frame(width: 30, height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text(currency.code)
                        Spacer()
                        Text(currency.name)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Currency")
        }
    }
}
