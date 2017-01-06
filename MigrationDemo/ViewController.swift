//
//  ViewController.swift
//  MigrationDemo
//
//  Created by shenyun on 2016/11/3.
//  Copyright © 2016年 shenyun. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //print(NSPersistentContainer.defaultDirectoryURL().path) // sql file storage path
        
        //print(Bundle.main.bundleURL.path) // data model dir storage path
        /* //
        if let app = UIApplication.shared.delegate as? AppDelegate {
            /*//
            
            let Pruse = NSEntityDescription.insertNewObject(forEntityName: "Person", into: app.persistentContainer.viewContext)
            Pruse.setValue("Pruse Ree", forKey: "name")
            
            // */
            
            app.saveContext()
        }
        // */
        /*
        let Pruse = NSEntityDescription.insertNewObject(forEntityName: "Person", into: DataHandler.shared.context)
        
        Pruse.setValue("Pruse Ree", forKey: "name")
        
        
        // */
        
        DataHandler.shared.saveContext()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

