//
//  FoodItems.swift
//  Foodzilla
//
//  Created by Ricardo Herrera Petit on 3/20/19.
//  Copyright © 2019 Ricardo Herrera Petit. All rights reserved.
//

import UIKit

let defaultPrice = 9.99

let salmon = Item(image: UIImage(named: "food1")!, name: "Salmon", price: defaultPrice)
let cheeseburguer = Item(image: UIImage(named: "food2")!, name: "Cheeseburguer", price: defaultPrice)
let burrito = Item(image: UIImage(named: "food3")!, name: "Burrito", price: defaultPrice)
let spaghuetti = Item(image: UIImage(named: "food4")!, name: "Spaghetti", price: defaultPrice)
let pizza = Item(image: UIImage(named: "food5")!, name: "Pizza", price: defaultPrice)
let salad = Item(image: UIImage(named: "food6")!, name: "Salad", price: defaultPrice)

let foodItems: [Item] = [salmon, cheeseburguer, burrito, spaghuetti, pizza, salad]

