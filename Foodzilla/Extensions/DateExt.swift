//
//  DateExt.swift
//  Foodzilla
//
//  Created by Ricardo Herrera Petit on 3/24/19.
//  Copyright © 2019 Ricardo Herrera Petit. All rights reserved.
//

import Foundation

extension Date {
    func isLessThan(_ date: Date) -> Bool {
        if self.timeIntervalSince(date) < date.timeIntervalSinceNow {
            return true
        } else {
            return false
        }
    }
}
