//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "AD0AADAE-5C65-47E0-8A31-5A6B947D6E83"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        //Creamos la url completa añadiendo currency y el apiKey
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        //desempaquetar urlString para crear una URL
        if let url = URL(string: urlString) {
            
            //Crear un nuevo objeto URLSession con la configuracion .default.
            let session = URLSession(configuration: .default)
            
            //Crear un nuevo dataTask para el URLSession
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                //Formatear los datos que recibimos a String para poder imprimir
                if let safeData = data {
                    if let bitcoinPrice = parseJSON(safeData) {
                        //OPCIONAL: redondear el precio a 2 decimales.
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        //Llamar al metodo delegado en el delegado (ViewController) pasandole la inforamción necesaria.
                        delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            //Empezar la task para recuperar los datos del servidor
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }

    
}
