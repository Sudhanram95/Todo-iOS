//
//  Item.swift
//  Todoey
//
//  Created by Sudhan Ram on 14/04/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isChecked: Bool = false
    @objc dynamic var timeStamp: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
