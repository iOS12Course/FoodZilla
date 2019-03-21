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
        // Do any additional setup after loading the view, typically from a nib.
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
    
    @IBAction func restoreBtnWasPressed(_ sender: Any) {
    }
    
}

extension StorefrontVC : IAPServiceDelegate {
    func iapProducstLoaded() {
        print("IAP PRODUCTS LOADED")
    }
    
    
}
