//
//  Person2To3.swift
//  MigrationDemo
//
//  Created by shenyun on 2016/11/3.
//  Copyright © 2016年 shenyun. All rights reserved.
//

import CoreData

class Person2To3: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let dInstance: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
        
        
        let firstname: String = sInstance.value(forKey: "firstname") as! String
        
        let lastname: String = sInstance.value(forKey: "lastname") as! String
        
        dInstance.setValue("\(firstname)-\(lastname)", forKey: "username")
        
        
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
    }
}
