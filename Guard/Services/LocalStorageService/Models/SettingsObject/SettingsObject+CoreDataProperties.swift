//
//  SettingsObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 18.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension SettingsObject {

	convenience init(settingsModel: SettingsModel, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "SettingsObject", in: context)!
		self.init(entity: entity, insertInto: context)
		
		self.id = Int64(settingsModel.id)
		self.isPhoneVisible = settingsModel.isPhoneVisible
		self.isEmailVisible = settingsModel.isEmailVisible
		self.isChatEnabled = settingsModel.isChatEnabled
	}

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsObject> {
        return NSFetchRequest<SettingsObject>(entityName: "SettingsObject")
    }

    @NSManaged public var id: Int64
    @NSManaged public var isPhoneVisible: Bool
    @NSManaged public var isEmailVisible: Bool
    @NSManaged public var isChatEnabled: Bool

}

extension SettingsObject : Identifiable {

}
