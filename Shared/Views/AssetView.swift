//
//  AssetView.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import SwiftUI
import Combine

struct AssetView: View {
    var ticker: String
    @State var cancellable: AnyCancellable?
    @State var openPrice = 0.0
    @State var closePrice = 0.0
    
    var body: some View {
        
        VStack {
            Text("Open: \(openPrice)")
            Text("Close: \(closePrice)")
        }
        .onAppear(perform: updateTickerData)
        .navigationTitle(ticker)
    }
    
    private func updateTickerData() {
        cancellable = PolygonAPI.previousClose(ticker: ticker)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { results in
                print(results)
                openPrice = results.results.first!.o
                closePrice = results.results.first!.c
            })
    }
}

//struct StockView_Previews: PreviewProvider {
//    static var previews: some View {
//        StockView()
//    }
//}
