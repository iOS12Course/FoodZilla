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
    
    var nonConsumablePurchaseWasMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseWasMade")
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func loadProducts() {
        productIdToStringSet()
        requestProducts(forIds: productIds)
    }
    
    func productIdToStringSet() {
        let ids = [IAP_HIDE_ADS_ID, IAP_MEAL_ID, IAP_MEALTIME_MONTHLY_SUB]
        for id in ids {
            productIds.insert(id)
        }
        
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
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension IAPService : SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                complete(transaction: transaction)
                debugPrint("Purchase was successful!!!")
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                sendNotificationFor(status: .failed, withIdentifier: nil, orBoolean: nil)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        sendNotificationFor(status: .restored, withIdentifier: nil, orBoolean: nil)
        setNonConsumablePurchase(true)
    }
    
    func complete(transaction: SKPaymentTransaction) {
        switch transaction.payment.productIdentifier {
        case IAP_MEALTIME_MONTHLY_SUB:
            sendNotificationFor(status: .subscribed, withIdentifier: transaction.payment.productIdentifier, orBoolean: true)
             setNonConsumablePurchase(true)
            break
        case IAP_MEAL_ID:
            sendNotificationFor(status: .purchased, withIdentifier: transaction.payment.productIdentifier, orBoolean: nil)
            break
        case IAP_HIDE_ADS_ID:
            setNonConsumablePurchase(true)
            break
        default:
            break
        }
    }
    
    func setNonConsumablePurchase(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: "nonConsumablePurchaseWasMade")
    }
    
    func sendNotificationFor(status:PurchaseStatus, withIdentifier identifier: String?, orBoolean bool:Bool?) {
        switch status {
        case .purchased:
            NotificationCenter.default.post(name: NSNotification.Name(IAPServicesPurchaseNotification), object: identifier)
            break
        case .restored:
            NotificationCenter.default.post(name: NSNotification.Name(IAPServicesRestoreNotification), object: nil)
            break
        case .failed:
            NotificationCenter.default.post(name: NSNotification.Name(IAPServicesFailureNotification), object: nil)
            break
        case .subscribed:
            NotificationCenter.default.post(name: NSNotification.Name(IAPSubInfoChangedNotification), object: bool)
            break
        }
    }
}
