//
//  IAPService.swift
//  Foodzilla
//
//  Created by Ricardo Herrera Petit on 3/20/19.
//  Copyright © 2019 Ricardo Herrera Petit. All rights reserved.
//

import Foundation
import StoreKit

protocol IAPServiceDelegate {
    func iapProducstLoaded()
}

class IAPService: NSObject, SKProductsRequestDelegate {
    static let instance = IAPService()
    
    var delegate: IAPServiceDelegate?
    
    var products = [SKProduct]()
    var productIds = Set<String>()
    
    var productRequest = SKProductsRequest()
    
    func loadProducts() {
        productIdToStringSet()
        requestProducts(forIds: productIds)
    }
    
    func productIdToStringSet() {
        productIds.insert(IAP_MEAL_ID)
    }
    
    func requestProducts(forIds ids: Set<String>) {
        productRequest.cancel()
        productRequest = SKProductsRequest(productIdentifiers: ids)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        for invalidIdentifier in response.invalidProductIdentifiers {
            print(invalidIdentifier)
        }
        if products.count == 0 {
            requestProducts(forIds: productIds)
        } else {
            delegate?.iapProducstLoaded()
            print(products[0].localizedTitle)
        }
    }
}


