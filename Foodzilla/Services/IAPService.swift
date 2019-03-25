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

class IAPService: SKReceiptRefreshRequest, SKProductsRequestDelegate {
    static let instance = IAPService()
    
    var iapDelegate: IAPServiceDelegate?
    
    var products = [SKProduct]()
    var productIds = Set<String>()
    var productRequest = SKProductsRequest()
    
    var expirationDate = UserDefaults.standard.value(forKey: "expirationDate") as? Date
    
    var nonConsumablePurchaseWasMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseWasMade")

    
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
            debugPrint("WARNING PRODUCTS ARE ZERO")
            requestProducts(forIds: productIds)
        } else {
            iapDelegate?.iapProducstLoaded()
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
    
    func requestDidFinish(_ request: SKRequest) {
        uploadReceipt { (valid) in
            if valid {
                debugPrint("SUBSCRPTION VALID")
                self.isSubscriptionActive(completionHandler: { (active) in
                    if active {
                        debugPrint("SUBSCRPTION ACTIVE")
                        self.sendNotificationFor(status: .subscribed, withIdentifier: nil, orBoolean: true)
                        self.setNonConsumablePurchase(true)
                    } else {
                          debugPrint("SUBSCRPTION EXPIRED")
                        self.sendNotificationFor(status: .subscribed, withIdentifier: nil, orBoolean: false)
                        self.setNonConsumablePurchase(false)
                    }
                })
            } else {
                  debugPrint("SUBSCRPTION INVALID")
                self.sendNotificationFor(status: .subscribed, withIdentifier: nil, orBoolean: false)
                self.setNonConsumablePurchase(false)
            }
        }
    }
    
    func isSubscriptionActive(completionHandler: @escaping (Bool) -> Void) {
        reloadExpiryDate()
        let nowDate = Date()
        debugPrint("TIME REMAINIG: ",( expirationDate?.timeIntervalSinceNow)! / 60, "MINUTES")
        guard let expirationDate = expirationDate else { return }
        if nowDate.isLessThan(expirationDate) {
            completionHandler(true)
        } else {
            completionHandler(false)
        }
        
    }
    
    func uploadReceipt(completionHandler: @escaping (Bool) -> Void) {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL , let receipt = try? Data(contentsOf: receiptUrl).base64EncodedString() else {
            debugPrint("No receipt url")
            completionHandler(false)
            return
        }
        
        let body = [
            "receipt-data": receipt,
            "password": appSecret
        ]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                debugPrint("Error: ", error)
                completionHandler(false)
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                let newExpirationDate = self.expirationDateFromResponse(jsonResponse: json)
                self.setExpiration(forDate: newExpirationDate!)
                debugPrint("NEW EXPIRATION DATE: ", newExpirationDate!)
                completionHandler(true)
            }
            
        }
        
        task.resume()
    }
    
    func expirationDateFromResponse(jsonResponse: Dictionary<String,Any>) -> Date? {
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            let lastReceipt = receiptInfo.lastObject as! Dictionary<String, Any>
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            let expirationDate: Date = formatter.date(from: lastReceipt["expires_date"] as! String) as Date!
            
            return expirationDate
        } else {
            return nil
        }
    }
    
    func setExpiration(forDate date:Date) {
        UserDefaults.standard.set(date, forKey: "expirationDate")
    }
    
    func reloadExpiryDate() {
        expirationDate = UserDefaults.standard.value(forKey: "expirationDate") as? Date
    }
    
}

extension IAPService : SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                debugPrint("Purchase was successful!!!")
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                sendNotificationFor(status: .failed, withIdentifier: nil, orBoolean: nil)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .purchasing:
                debugPrint("Purchasing...")
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
            self.sendNotificationFor(status: .subscribed, withIdentifier: nil, orBoolean: true)
            self.setNonConsumablePurchase(true)
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
