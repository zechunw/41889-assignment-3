//
//  Myuser+CoreDataProperties.swift
//  signin&signup
//
//  Created by Zechun Wang on 2023/5/7.
//
//

import Foundation
import CoreData


extension Myuser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Myuser> {
        return NSFetchRequest<Myuser>(entityName: "Myuser")
    }

    @NSManaged public var userAccount: String?
    @NSManaged public var userPwd: String?
    @NSManaged public var userType: String?

}

extension Myuser : Identifiable {

}
