//
//  ViewController.swift
//  Foodzilla
//
//  Created by Ricardo Herrera Petit on 3/19/19.
//  Copyright © 2019 Ricardo Herrera Petit. All rights reserved.
//

import UIKit

class StorefrontVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        IAPService.instance.delegate = self
        IAPService.instance.loadProducts()
        NotificationCenter.default.addObserver(self, selector: #selector(showRestoredAlert), name: NSNotification.Name(IAPServicesRestoreNotification), object: nil)
    }
    
    @objc func showRestoredAlert() {
        let alertVC = UIAlertController(title: "Success!", message: "Your purchases were successfully restored", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else { return UICollectionViewCell() }
        let item = foodItems[indexPath.row]
        cell.configureCell(forItem: item)
        return cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailVC else { return }
        let item = foodItems[indexPath.row]
        detailVC.initData(forItem: item)
        present(detailVC, animated: true, completion: nil)
        
    }
    
    @IBAction func subscribeBtnWasPressed(_ sender: Any) {
        IAPService.instance.attemptPurchaseForItemWith(productIndex: .monthlySub)
    }
    
    @IBAction func restoreBtnWasPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "Restore Purchases?", message: "Do you want to restore any in-app purchases you previously purchased?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Restore", style: .default) { (action) in
            IAPService.instance.restorePurchases()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(action)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)

    }
    
}

extension StorefrontVC : IAPServiceDelegate {
    func iapProducstLoaded() {
        print("IAP PRODUCTS LOADED")
    }
    
    
}
