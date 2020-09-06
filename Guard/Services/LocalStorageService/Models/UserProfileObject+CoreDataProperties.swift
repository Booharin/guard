//
//  UserProfileObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 06.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension UserProfileObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileObject> {
        return NSFetchRequest<UserProfileObject>(entityName: "UserProfileObject")
    }

    @NSManaged public var email: String?
    @NSManaged public var userType: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var city: String?

}
