//
//  Settings.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/09/2025.
//

import Foundation

import SwiftData

@Model
final class Settings {

    var proUnlocked: Bool
    var iCloudSyncOn: Bool
    var currencyCode: String          // e.g., "PKR"
    

    init(onboardingComplete: Bool = false,
         proUnlocked: Bool = false,
         iCloudSyncOn: Bool = false,
         currencyCode: String = "PKR",
        )
        {
     
        self.proUnlocked = proUnlocked
        self.iCloudSyncOn = iCloudSyncOn
        self.currencyCode = currencyCode
       
    }
}
