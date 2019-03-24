//
//  DataController.swift
//  VirtualTourist
//
//  Created by Khaled Shuwaish on 24/02/2019.
//  Copyright © 2019 Khaled Shuwaish. All rights reserved.
//

import Foundation
import CoreData
class DataController {
    let PersistentContainer : NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return PersistentContainer.viewContext
    }
    init(modelName:String) {
        PersistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(){
        PersistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
        }
    }
}
