//
//  Product.swift
//  Checkout
//
//  Created by Bryan Gula on 6/27/17.
//  Copyright © 2017 Gula, Inc. All rights reserved.
//

import Foundation
import UIKit

struct Product {
    
    var name : String?
    var serving : String?
    var usdPrice : Double?
    
}

struct Currency {
    var name : String?
    var usdConvertionRate : Double?
}

struct CartManager {
    
    var cart : [Product] = []
    private(set) var currencyManager = CurrencyManager()
    private(set) var inventory : [Product] = CartManager.buildInventory()
    fileprivate let inventoryImages = [UIImage(named: "Peas"), UIImage(named: "Eggs"), UIImage(named: "Milk"), UIImage(named: "Beans")]
    
    mutating func add(product : Product) {
        cart.append(product)
    }
    
    mutating func clearCart() {
        cart.removeAll()
    }
    
    func totalInUSD() -> Double {
        return self.cart.reduce(0) { $0 + $1.usdPrice! }
    }
    
    func totalIn(currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let currencyCode = currency.name?.substring(from:(currency.name?.index((currency.name?.startIndex)!, offsetBy: 3))!)
        let currencyDictionary : [String:String] = [currencyCode! : NSLocale.Key.currencyCode.rawValue]
        let currencyLocaleComponents = NSLocale.localeIdentifier(fromComponents: currencyDictionary)
        let currencyLocale = NSLocale.init(localeIdentifier: currencyLocaleComponents)
        
        formatter.locale = currencyLocale as Locale!
        
        let cartValue = self.totalInUSD() * currency.usdConvertionRate!
        
        return formatter.string(from: NSNumber(value: cartValue))!
    }
    
    func numberOfItemsInInventory() -> Int {
        return self.inventory.count
    }
    
    func numberOfItemsInCart() -> Int {
        return self.cart.count
    }
    
    func imageForProduct(product: Product) -> UIImage? {
        return UIImage(named: product.name!)
    }
    
    static func buildInventory() -> [Product] {
        let milk = Product(name: "Milk", serving: "bottle", usdPrice: 1.30)
        let peas = Product(name: "Peas", serving: "bag", usdPrice: 0.95)
        let beans = Product(name: "Beans", serving: "can", usdPrice: 0.73)
        let eggs = Product(name: "Eggs", serving: "dozen", usdPrice: 2.10)
        return [peas, milk, beans, eggs]
    }
}

struct CurrencyManager {
    
    static var shared = CurrencyManager()
    var currencyTypes : [Currency] = []
    
    internal init() {
        CurrencyManager.fetchRates(success: { (rates) in
            let quotes = rates["quotes"] as! [String : Double]
            for currencyName in quotes.keys {
                CurrencyManager.shared.currencyTypes.append(Currency(name: currencyName, usdConvertionRate: quotes[currencyName]))
            }
        }) { (error) in
            print(error)
        }
    }
    
    static func fetchRates(success: @escaping ([String:Any]) -> Void, failure: @escaping (Error) -> Void) {

        var url = URL(string: "http://www.apilayer.net/api/live")
        
        let URLParams = ["access_key": "7752ed4ffbc6fc4b22e7172d1aab5efa"]
        url = url?.appendingQueryParameters(URLParams)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                success((try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]))
            } else {
                failure(error!)
            }
        })
        
        task.resume()
        URLSession.shared.finishTasksAndInvalidate()
    }
}


protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
     */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}
