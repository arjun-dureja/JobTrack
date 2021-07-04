//
//  FilterStatus.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2021-07-04.
//  Copyright © 2021 Arjun Dureja. All rights reserved.
//

import Foundation

enum FilterStatus: String {
    case byDate = "BY DATE"
    case byStatus = "BY STATUS"
    case aToZ = "A - Z"
    case favorites = "FAVORITES"

    func callAsFunction() -> String {
        return self.rawValue
    }
}
