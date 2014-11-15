//
//  Exchange.swift
//  ExchangeRate
//
//  Created by Kj Drougge on 2014-11-15.
//  Copyright (c) 2014 kj. All rights reserved.
//

import Foundation
import CoreData

class Exchange: NSManagedObject {

    @NSManaged var currency: String
    @NSManaged var rate: NSNumber

}
