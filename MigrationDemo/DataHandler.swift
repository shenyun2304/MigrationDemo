//
//  DataHandler.swift
//  MigrationDemo
//
//  Created by shenyun on 2016/11/3.
//  Copyright © 2016年 shenyun. All rights reserved.
//

import CoreData

class DataHandler: NSObject {
    // 1. define db file location
    
    lazy fileprivate var dbFileUrl = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("database.sqlite")
    // 2. locate data model dir url
    
    lazy fileprivate var dataModelDirUrl = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
    
    // 3. is migration needed ??
    
    fileprivate func isMigrationNeed() -> Bool {
        do {
            // I. get sql file meta data
            let sMetaData = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: dbFileUrl, options: nil)
            
            return !currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sMetaData)
        } catch {
            print("is migration needed error: \(error)")
        }
        
        return false
    }
    
    
    // 4. do migrate
    
    fileprivate func migrate() {
        do {
            let sMetaData = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: dbFileUrl, options: nil)
            let sDataModel = NSManagedObjectModel.mergedModel(from: [Bundle.main], forStoreMetadata: sMetaData)
            
            print("source data model id: \(sDataModel?.versionIdentifiers)")
            print("current data model id: \(currentModel.versionIdentifiers)")
            
            if let sVersionInfo = sDataModel?.versionIdentifiers {
                let dVersionInfo = currentModel.versionIdentifiers
                let sVersionId:Int = Int(sVersionInfo.description.components(separatedBy: "_")[1])!
                let dVersionId:Int = Int(dVersionInfo.description.components(separatedBy: "_")[1])!
                
                let modelUrls: [URL] = Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: dataModelDirUrl.lastPathComponent)!
                
                var dataModels: [String: NSManagedObjectModel] = [:]
                
                for moUrl in modelUrls {
                    let dataModel: NSManagedObjectModel = NSManagedObjectModel(contentsOf: moUrl)!
                    
                    if let dataModelVersionId = dataModel.versionIdentifiers.first?.description {
                        dataModels[dataModelVersionId] = dataModel
                    }
                }
                
                
                
                let mappingUrls: [URL] = Bundle.main.urls(forResourcesWithExtension: "cdm", subdirectory: nil)!
                
                var mappingModels: [String: NSMappingModel] = [:]
                
                for mpUrl in mappingUrls {
                    let mappingFileName = mpUrl.lastPathComponent
                    let mappingKey = "_\(mappingFileName.components(separatedBy: ".")[0].characters.last!)_"
                    
                    mappingModels[mappingKey] = NSMappingModel(contentsOf: mpUrl)
                }
                
                for i in sVersionId..<dVersionId {
                    let sDataModel: NSManagedObjectModel = dataModels["_\(i)_"]!
                    let dDataModel: NSManagedObjectModel = dataModels["_\(i+1)_"]!
                    
                    let mpModel: NSMappingModel = mappingModels["_\(i+1)_"]!
                    
                    do {
                        let tempUrl: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("temp.sqlite")
                        let migrateMgr: NSMigrationManager = NSMigrationManager(sourceModel: sDataModel, destinationModel: dDataModel)
                        
                        try migrateMgr.migrateStore(from: dbFileUrl, sourceType: NSSQLiteStoreType, options: nil, with: mpModel, toDestinationURL: tempUrl, destinationType: NSSQLiteStoreType, destinationOptions: nil)
                        
                        try FileManager.default.removeItem(at: dbFileUrl)
                        try FileManager.default.copyItem(at: tempUrl, to: dbFileUrl)
                        try FileManager.default.removeItem(at: tempUrl)
                        
                        print("migrate from v:\(i) to v:\(i+1) success")
                    } catch {
                        print("migrate process error: \(error)")
                    }
                    
                }
                
                
            }
            
            
        } catch {
            print("migrate error: \(error)")
        }
    }
    
    // 5. combine final sql file and current data model
    
    fileprivate func load() {
        
        if persistenStore == nil {
            if !addPersistentStore() {
                abort()
            }
        }
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        context.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    // 6. core data objects: PersistentStoreCoordinator, ManagedObjectModel, ManagedObjectContext, PersistentObjectStore
    
    fileprivate var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    fileprivate var currentModel: NSManagedObjectModel!
    fileprivate var persistenStore: NSPersistentStore!
    
    var context: NSManagedObjectContext!
    
    
    override init() {
        super.init()
        currentModel = NSManagedObjectModel(contentsOf: dataModelDirUrl)!
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: currentModel)
        
        
        print(dbFileUrl.path)
        
        if !FileManager.default.fileExists(atPath: dbFileUrl.path) {
            addPersistentStore()
        }
        start()
    }
    
    @discardableResult
    fileprivate func addPersistentStore() -> Bool {
        do {
            persistenStore = try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbFileUrl, options: nil)
            
            /*
             [
             NSMigratePersistentStoresAutomaticallyOption: true,
             NSInferMappingModelAutomaticallyOption: true
             ]
            // */
            
            return true
        } catch {
            print("add persistent store error: \(error)")
        }
        return false
    }
    
    
    fileprivate func start() {
        if isMigrationNeed() {
            migrate()
        }
        
        load()
    }
    
    // 7. for use
    
    static var shared: DataHandler = DataHandler()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("save context error: \(nserror.userInfo)")
            }
        }
    }
    
}
