//
//  Category.swift
//  Todoey
//
//  Created by Sudhan Ram on 14/04/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var background: String = "#FFFFFF"
    let items = List<Item>()
}
