//
//  CheckoutViewController.swift
//  Checkout
//
//  Created by Bryan Gula on 6/29/17.
//  Copyright © 2017 Gula, Inc. All rights reserved.
//

import UIKit

class CheckoutViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var cartManager : CartManager?
    var currencyManager = CurrencyManager.shared
    
    @IBOutlet var currentCurrencyLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var currencyCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        totalLabel.text = formatter.string(from: NSNumber(value: cartManager!.totalInUSD()))
    }
    
    
    @IBAction func convertBackToUSD(_ sender: Any) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        totalLabel.text = formatter.string(from: NSNumber(value: cartManager!.totalInUSD()))
    }
    
    @IBAction func cancelCheckout(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finishCheckout(_ sender: Any) {
        cartManager!.clearCart()
        dismiss(animated: true, completion: nil)
    }
    
    //  MARK: CollectionView Delegate & Data Source
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "currencyCell", for: indexPath) as! CurrencyTypeCollectionViewCell
        
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 2.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        let index = (indexPath.item + 1) * (indexPath.section + 1)
        let currency = currencyManager.currencyTypes[index]
        let currencyCode = currency.name?.substring(from:(currency.name?.index((currency.name?.startIndex)!, offsetBy: 3))!)

        cell.currencyName.text = currencyCode
        
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currencyManager.currencyTypes.count / 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = (indexPath.item + 1) * (indexPath.section + 1)

        let currency = currencyManager.currencyTypes[index]
        let currencyCode = currency.name?.substring(from:(currency.name?.index((currency.name?.startIndex)!, offsetBy: 3))!)
        DispatchQueue.main.async {
            self.totalLabel.text = self.cartManager?.totalIn(currency: currency)
            self.currentCurrencyLabel.text = currencyCode
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 4.8, height: 40)
    }
}

class CurrencyTypeCollectionViewCell : UICollectionViewCell {

    @IBOutlet var currencyName: UILabel!
    
}

