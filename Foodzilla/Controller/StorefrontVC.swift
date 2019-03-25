//
//  ViewController.swift
//  Foodzilla
//
//  Created by Ricardo Herrera Petit on 3/19/19.
//  Copyright © 2019 Ricardo Herrera Petit. All rights reserved.
//

import UIKit

class StorefrontVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var foodZillaLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var subscriptionStatusLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        IAPService.instance.iapDelegate = self
        IAPService.instance.loadProducts()
        NotificationCenter.default.addObserver(self, selector: #selector(showRestoredAlert), name: NSNotification.Name(IAPServicesRestoreNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStatusWasChanged(_:)), name: NSNotification.Name(IAPSubInfoChangedNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func subscriptionStatusWasChanged(_ notification: Notification) {
        guard let status = notification.object as? Bool else { return }
        DispatchQueue.main.async {
            if status  {
                self.view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                self.collectionView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                self.subscriptionStatusLbl.text = "SUBSCRIPTION ACTIVE"
                self.subscriptionStatusLbl.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                self.foodZillaLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.subscriptionStatusLbl.text = "SUBSCRIPTION EXPIRED"
                self.subscriptionStatusLbl.textColor = #colorLiteral(red: 0.8235294118, green: 0.3137254902, blue: 0.3058823529, alpha: 1)
                self.foodZillaLbl.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IAPService.instance.isSubscriptionActive { (active) in }
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
