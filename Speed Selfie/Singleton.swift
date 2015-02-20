//
//  Singleton.swift
//  Speed Selfie
//
//  Created by Vaibhav Gandhi on 2/7/15.
//  Copyright (c) 2015 Vaibhav Gandhi. All rights reserved.
//

import UIKit

private let _singletonInstance = Singleton()

class Singleton: NSObject {

    var contactDetail : NSDictionary
    class var sharedInstance : Singleton {
        return _singletonInstance;
    }
    
    override init() {
        contactDetail = ["firstName":"","lastName":""];
    }
}
