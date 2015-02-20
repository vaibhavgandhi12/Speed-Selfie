//
//  Person.swift
//  Speed Selfie
//
//  Created by Vaibhav Gandhi on 2/7/15.
//  Copyright (c) 2015 Vaibhav Gandhi. All rights reserved.
//

import Foundation
import CoreData
@objc(Person)

class Person: NSManagedObject {

    @NSManaged var contact: String
    @NSManaged var image: NSData
    @NSManaged var name: String
    @NSManaged var personID: NSNumber
    @NSManaged var isImageAvailable: NSNumber

}
