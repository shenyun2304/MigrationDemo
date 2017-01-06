//
//  Person1To2.swift
//  MigrationDemo
//
//  Created by shenyun on 2016/11/3.
//  Copyright © 2016年 shenyun. All rights reserved.
//

import CoreData

class Person1To2: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let dInstance: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
        
//        for key in sInstance.entity.attributesByName.keys {
//            dInstance.setValue(sInstance.value(forKey: key), forKey: key)
//        }
        
        if let sName: String = sInstance.value(forKey: "name") as! String? {
            let splitName: [String] = sName.components(separatedBy: " ")
            
            
            if splitName.count >= 2 {
                dInstance.setValue(splitName[0], forKey: "firstname")
                dInstance.setValue(splitName[1], forKey: "lastname")
            } else {
                dInstance.setValue(sName, forKey: "firstname")
            }
            
            dInstance.setValue(sName, forKey: "fullname")
            
        }
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
        
    }
}
