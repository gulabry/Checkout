//
//  ViewController.swift
//  Checkout
//
//  Created by Bryan Gula on 6/27/17.
//  Copyright © 2017 Gula, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    var cartManager = CartManager()

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var checkoutButton: UIButton!
    @IBOutlet var totalCartItems: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cartManager.numberOfItemsInCart() == 0 {
            checkoutButton.isEnabled = false
        } else {
            checkoutButton.isEnabled = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        totalCartItems.layer.cornerRadius = totalCartItems.frame.width/2
        totalCartItems.layer.masksToBounds = true
        totalCartItems.layer.backgroundColor = #colorLiteral(red: 0.8056450486, green: 0.3072642088, blue: 0.2196787, alpha: 1).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        totalCartItems.text = "\(cartManager.numberOfItemsInCart())"
    }
    
    //  MARK: TableView Delegate & Data Source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let product = cartManager.cart[indexPath.row]
        cell.textLabel?.text = product.name
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        cell.detailTextLabel?.text = formatter.string(from: NSNumber(value: product.usdPrice!))
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartManager.numberOfItemsInCart()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            cartManager.cart.remove(at: indexPath.row)
            totalCartItems.text = "\(cartManager.numberOfItemsInCart())"
            tableView.reloadData()
        }
    }
    
    //  MARK: CollectionView Delegate & Data Source

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCell
        
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
        
        let product = cartManager.inventory[indexPath.row]
        
        cell.imageView.image = cartManager.imageForProduct(product: product)
        cell.name.text = product.name
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
                
        cell.price.text = formatter.string(from: NSNumber(value: product.usdPrice!))
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let product = self.cartManager.inventory[indexPath.row]
            self.cartManager.add(product: product)
            self.totalCartItems.text = "\(self.cartManager.numberOfItemsInCart())"
            self.checkoutButton.isEnabled = true
            self.tableView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartManager.numberOfItemsInInventory()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 3.4, height: collectionView.frame.height * 0.93)
    }


    //  MARK: Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCheckout" {
            let checkoutVC = segue.destination as! CheckoutViewController
            checkoutVC.cartManager = self.cartManager
        }
    }
}

class ProductCell : UICollectionViewCell {
  
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var price: UILabel!
}

class CartTableViewCell : UITableViewCell {
    
    @IBOutlet var removeLabel: UILabel!
    @IBOutlet var productLabel: UILabel!
    
    
}

