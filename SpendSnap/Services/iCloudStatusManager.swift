//
//  iCloudStatusManager.swift
//  SpendSnap
//
//  Created by Ahmad Ali Tariq on 30/11/2025.
//

import Foundation
import CloudKit

enum ICloudStatus {
    case unknown
    case available
    case noAccount
    case restricted
    case couldNotDetermine
    case temporarilyUnavailable
}

@MainActor
final class ICloudStatusViewModel: ObservableObject {
    @Published var status: ICloudStatus = .unknown

    func refresh() async {
        do {
            let accountStatus = try await CKContainer.default().accountStatus()
            switch accountStatus {
            case .available:
                status = .available
            case .noAccount:
                status = .noAccount
            case .restricted:
                status = .restricted
            case .couldNotDetermine:
                status = .couldNotDetermine
            case .temporarilyUnavailable:
                status = .temporarilyUnavailable
            @unknown default:
                status = .couldNotDetermine
            }
        } catch {
            status = .couldNotDetermine
        }
    }
}
