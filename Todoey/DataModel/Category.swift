//
//  Category.swift
//  Todoey
//
//  Created by Mac on 26.10.2018.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
