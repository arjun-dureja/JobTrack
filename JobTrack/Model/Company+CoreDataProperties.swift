//
//  Company+CoreDataProperties.swift
//  JobTrack
//
//  Created by Arjun Dureja on 2020-08-01.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//
//

import Foundation
import CoreData

extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var companyName: String
    @NSManaged public var jobPosition: String
    @NSManaged private var status: String
    var applicationStatus: ApplicationStatus {
        get {
            return ApplicationStatus(rawValue: self.status) ?? ApplicationStatus.applied
        }
        set {
            self.status = newValue.rawValue
        }
    }

    @NSManaged public var isFavorite: Bool
    @NSManaged public var dateAdded: Date
}
