//
//  ClientAppealObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension ClientAppealObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClientAppealObject> {
        return NSFetchRequest<ClientAppealObject>(entityName: "ClientAppealObject")
    }

    @NSManaged public var title: String?
    @NSManaged public var issueType: String?
    @NSManaged public var appealDescription: String?
    @NSManaged public var dateCreate: Double

}
