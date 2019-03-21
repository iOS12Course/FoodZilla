//
//  DetailVC.swift
//  Foodzilla
//
//  Created by Ricardo Herrera Petit on 3/20/19.
//  Copyright © 2019 Ricardo Herrera Petit. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var itemPriceLbl: UILabel!
    @IBOutlet weak var uglyAdView: UIView!
    @IBOutlet weak var buyItemBtn: UIButton!
    @IBOutlet weak var hideAdsBtn: UIButton!
    
    public private (set) var item:Item!
    
    func initData(forItem item:Item) {
       self.item = item
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemImageView.image = item.image
        itemNameLbl.text = item.name
        itemPriceLbl.text = String(describing: item.price)
        buyItemBtn.setTitle("Buy this for $(\(item.price))", for: .normal)
    }
    
    @IBAction func buyBtnWasPressed(_ sender: Any) {
    }
    
    @IBAction func hideAdsBtnWasPressed(_ sender: Any) {
    }
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
