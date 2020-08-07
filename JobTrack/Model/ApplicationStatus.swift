//
//  ApplicationStatus.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-07-26.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import Foundation

enum ApplicationStatus: String, Comparable {
    case applied = "APPLIED"
    case phoneScreen = "PHONE SCREEN"
    case onSite = "ON SITE"
    case offer = "OFFER"
    case rejected = "REJECTED"
    
    private var sortOrder: Int {
        switch self {
        case .offer:
            return 0
        case .onSite:
            return 1
        case .phoneScreen:
            return 2
        case .applied:
            return 3
        case .rejected:
            return 4
        }
    }
    
    static func ==(lhs: ApplicationStatus, rhs: ApplicationStatus) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }
    
    static func <(lhs: ApplicationStatus, rhs: ApplicationStatus) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
    
}
