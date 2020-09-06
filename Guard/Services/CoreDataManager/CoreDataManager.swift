//
//  CoreDataManager.swift
//  Guard
//
//  Created by Alexandr Bukharin on 06.09.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import Foundation
import CoreData

/**
 Helps to operate the core data stack
 
 - Usage example
    ````
    // Init core data manager
    let coreDataManager = CoreDataManager(withDataModelName: "coreDataModelNameHere", bundle: .main)

    // Add some objects of entity
    let testObj = SomeEntity(context: coreDataManager.mainContext)
    testObj.name = "kekus2"

    // Save managedobjectcontext:
    coreDataManager.saveContext(synchronously: true)

    // Fetch:
    let fetchResult = coreDataManager.fetchObjects(entity: SomeEntity.self, context: coreDataManager.mainContext)
    for data in fetchResult {
        print(data.name ?? "nil")
    }
    `````
*/
final class CoreDataManager {
    // MARK: - Static properties
    private static var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return urls[urls.count - 1]
    }()

    // MARK: - Public properties
    lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = privateContext

        return context
    }()

    // MARK: - Private properties
    private var dataModelName: String
    private var dataModelBundle: Bundle
    private var persistentStoreName: String

    // MARK: - Core data stack
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let url = CoreDataManager.applicationDocumentsDirectory.appendingPathComponent("\(persistentStoreName).sqlite")

        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch let error as NSError {
            fatalError("Failed to init persistent data: \(error.localizedDescription)")
        } catch {
            fatalError("Failed to init persistent data")
        }

        return coordinator
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = dataModelBundle.url(forResource: dataModelName, withExtension: "momd") else {
            fatalError("Failed to find data model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create managed object model")
        }

        return managedObjectModel
    }()

    // We use stack with a private context as the root with public context as its child
    // This method provides async write to disk
    private lazy var privateContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator

        return context
    }()

    // MARK: - Init
    init(withDataModelName dataModelName: String, bundle: Bundle = .main) {
        self.dataModelName = dataModelName
        self.persistentStoreName = dataModelName
        self.dataModelBundle = bundle
    }
}

// MARK: - Public methods
extension CoreDataManager {
    // MARK: - Child context
    func createChildContext(withParent parent: NSManagedObjectContext) -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = parent

        return managedObjectContext
    }

    // MARK: - Fetching
    func fetchObjects<T: NSManagedObject>(
        entity: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        context: NSManagedObjectContext,
        fetchBatchSize: Int? = nil
    ) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        if let fetchBatchSize = fetchBatchSize {
            request.fetchBatchSize = fetchBatchSize
        }

        do {
            return try context.fetch(request)
        } catch {
			// handle error
            return [T]()
        }
    }

    func fetchObject<T: NSManagedObject>(
        entity: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        context: NSManagedObjectContext
    ) -> T? {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
			// handle error
			return nil
		}
    }

    // MARK: - Deleting
    func delete(_ object: NSManagedObject) {
        mainContext.delete(object)
    }

    func delete(_ object: NSManagedObject, in context: NSManagedObjectContext) {
        context.delete(object)
    }

    func delete(_ objects: [NSManagedObject]) {
        for object in objects {
            mainContext.delete(object)
        }
    }

    func delete(_ objects: [NSManagedObject], in context: NSManagedObjectContext) {
        for object in objects {
            context.delete(object)
        }
    }

    func deleteAllObjects() {
        for entityName in managedObjectModel.entitiesByName.keys {
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            request.includesPropertyValues = false

            do {
                for object in try mainContext.fetch(request) {
                    mainContext.delete(object)
                }
			} catch {
                // handle error
            }
        }
    }

    // MARK: - Saving
    func saveContext(synchronously: Bool = true, completion: ((NSError?) -> Void)? = nil) {
        var mainContextSaveError: NSError?

        if mainContext.hasChanges {
            mainContext.performAndWait {
                do {
                    try mainContext.save()
                } catch let error as NSError {
                    mainContextSaveError = error
                }
            }
        }

        guard mainContextSaveError == nil else {
            completion?(mainContextSaveError)
            return
        }

        func savePrivateContext() {
            do {
                try privateContext.save()
                completion?(nil)
            } catch let error as NSError {
                completion?(error)
            }
        }

        if privateContext.hasChanges {
            if synchronously {
                privateContext.performAndWait(savePrivateContext)
            } else {
                privateContext.perform(savePrivateContext)
            }
        }
    }
}

