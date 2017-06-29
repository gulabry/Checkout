//
//  CheckoutViewController.swift
//  Checkout
//
//  Created by Bryan Gula on 6/29/17.
//  Copyright © 2017 Gula, Inc. All rights reserved.
//

import UIKit

//, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

class CheckoutViewController: UIViewController {
    
    var cartManager : CartManager?
    let currencyManager = CurrencyManager()
    
    
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var currencyCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        totalLabel.text = "$\(cartManager!.totalInUSD())"
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
        
        let currency = currencyManager.currencyTypes[indexPath.row]
        cell.currencyName.text = currency.name
        
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currencyManager.currencyTypes.count / 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CurrencyTypeCollectionViewCell
        let currency = currencyManager.currencyTypes[indexPath.row]
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: { 
                if cell.backgroundColor! == #colorLiteral(red: 0.01784582622, green: 0.6800052524, blue: 0.5928025842, alpha: 1) {
                    cell.backgroundColor = #colorLiteral(red: 0.1939424276, green: 0.5777522922, blue: 0.775141716, alpha: 1)
                } else {
                    cell.backgroundColor = #colorLiteral(red: 0.01784582622, green: 0.6800052524, blue: 0.5928025842, alpha: 1)
                }
            })
            
            self.totalLabel.text = self.cartManager?.totalIn(currency: currency)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 4, height: 100)
    }
}

class CurrencyTypeCollectionViewCell : UICollectionViewCell {

    @IBOutlet var currencyName: UILabel!
    
}

