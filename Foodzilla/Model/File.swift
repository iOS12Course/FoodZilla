//
//  File.swift
//  Foodzilla
//
//  Created by Ricardo Herrera Petit on 3/20/19.
//  Copyright © 2019 Ricardo Herrera Petit. All rights reserved.
//

import UIKit

class Item {
    public private (set) var image: UIImage
    public private (set) var name: String
    public private (set) var price: Double
    
    init(image:UIImage, name:String, price:Double) {
        self.image = image
        self.name = name
        self.price = price
    }
    
}

