//
//  ClientAppealObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 10.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension ClientAppealObject {
	
	convenience init(clientAppeal: ClientAppeal, context: NSManagedObjectContext) {
			let entity = NSEntityDescription.entity(forEntityName: "ClientAppealObject", in: context)!
			self.init(entity: entity, insertInto: context)

			self.appealDescription = clientAppeal.appealDescription
			self.issueCode = Int64(clientAppeal.issueCode)
			self.title = clientAppeal.title
			self.id = Int64(clientAppeal.id)
			self.dateCreated = clientAppeal.dateCreated
			self.clientId = Int64(clientAppeal.clientId)
			self.cityTitle = clientAppeal.cityTitle
			self.lawyerChoosed = clientAppeal.lawyerChoosed ?? false
		}

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClientAppealObject> {
        return NSFetchRequest<ClientAppealObject>(entityName: "ClientAppealObject")
    }

    @NSManaged public var appealDescription: String?
    @NSManaged public var issueCode: Int64
    @NSManaged public var title: String?
    @NSManaged public var id: Int64
    @NSManaged public var dateCreated: String?
    @NSManaged public var clientId: Int64
    @NSManaged public var cityTitle: String?
    @NSManaged public var lawyerChoosed: Bool

}

extension ClientAppealObject : Identifiable {

}
