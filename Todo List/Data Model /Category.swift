//
//  Category.swift
//  Todo List
//
//  Created by Aaron Geist on 3/16/18.
//  Copyright © 2018 Aaron Geist. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {      // the Realm Object
    
    @objc dynamic var name : String = ""
    
    let items = List<Item>()  // relationship for database
    
}
