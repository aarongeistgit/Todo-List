//
//  Item.swift
//  Todo List
//
//  Created by Aaron Geist on 3/16/18.
//  Copyright © 2018 Aaron Geist. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") // parent relationship
    
}
