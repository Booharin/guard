//
//  CityObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 20.12.2020.
//  Copyright © 2020 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension CityObject {

	convenience init(cityModel: CityModel, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "CityObject", in: context)!
		self.init(entity: entity, insertInto: context)
		
		self.title = cityModel.title
		self.titleEn = cityModel.titleEn
		self.cityCode = Int64(cityModel.cityCode)
		self.countryCode = Int64(cityModel.countryCode)
	}

	@nonobjc public class func fetchRequest() -> NSFetchRequest<CityObject> {
		return NSFetchRequest<CityObject>(entityName: "CityObject")
	}

	@NSManaged public var title: String?
	@NSManaged public var titleEn: String?
	@NSManaged public var countryCode: Int64
	@NSManaged public var cityCode: Int64
}

extension CityObject : Identifiable {

}
