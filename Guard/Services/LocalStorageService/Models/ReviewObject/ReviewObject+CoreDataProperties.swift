//
//  ReviewObject+CoreDataProperties.swift
//  Guard
//
//  Created by Alexandr Bukharin on 14.01.2021.
//  Copyright © 2021 ds. All rights reserved.
//
//

import Foundation
import CoreData


extension ReviewObject {

	convenience init(reviewModel: UserReview, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "ReviewObject", in: context)!
		self.init(entity: entity, insertInto: context)
		
		self.reviewId = Int64(reviewModel.reviewId)
		self.reviewDescription = reviewModel.reviewDescription
		self.rating = reviewModel.rating
		self.senderId = Int64(reviewModel.senderId)
		self.receiverId = Int64(reviewModel.receiverId)
		self.dateCreated = reviewModel.dateCreated
	}

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReviewObject> {
        return NSFetchRequest<ReviewObject>(entityName: "ReviewObject")
    }

    @NSManaged public var reviewId: Int64
    @NSManaged public var reviewDescription: String?
    @NSManaged public var rating: Double
    @NSManaged public var senderId: Int64
    @NSManaged public var receiverId: Int64
    @NSManaged public var dateCreated: String?

}

extension ReviewObject : Identifiable {

}
