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
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
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
    
    func attemptPurchaseForItemWith(productIndex: Product) {
        let product = products[productIndex.rawValue]
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
}

extension IAPService : SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                debugPrint("Purchase was successful!!!")
                break
            case .restored:
                break
            case .failed:
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
}
