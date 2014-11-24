//
//  XMLParserTest.swift
//  ExchangeRate
//
//  Created by Kj Drougge on 2014-11-19.
//  Copyright (c) 2014 kj. All rights reserved.
//

import Foundation
import CoreData

class XMLParserTest: NSObject, NSXMLParserDelegate {
    
    var currencyDict: [String : Double] = [:]
    var currencyArray: [String] = []
    var latestParseTime: NSDate!
    
    var fetchRequest: NSFetchRequest!
    var asyncFetchRequest: NSAsynchronousFetchRequest!
    var exchange: [Exchange]! = []
    var time: [Time]! = []
    
    
    func checkTime(coreDataStack: CoreDataStack){
        println("checkTime")
        
        let parsedTime = loadTime(coreDataStack)
        
        if !parsedTime.hasTime{
            parseFromXml(coreDataStack)
        } else {
            loadData(coreDataStack)
        }
    }
    
    func saveData(coreDataStack: CoreDataStack){
        println("saveData")
        
        let fetchRequest = NSFetchRequest(entityName: "Exchange")
        var error: NSError? = nil
        
        // Count the objects found in the context from the fetch request
        let results = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        
        if results != 0 {
            var fetchError: NSError? = nil
            
            let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError)
            
            // Iterate trhough the results from the fetch and delete all the objects
            for object in results!{
                let cube = object as Exchange
                coreDataStack.context.deleteObject(cube)
            }
            
            coreDataStack.saveContext()
        }
        
        for var i = 0; i < currencyDict.count; ++i{
            // Create an entity object and import data to the context.
            let exchangeEntity = NSEntityDescription.entityForName("Exchange", inManagedObjectContext: coreDataStack.context)
            
            let exchange = Exchange(entity: exchangeEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            
            exchange.currency = currencyArray[i]
            exchange.rate = currencyDict[currencyArray[i]]!
        }
        
        coreDataStack.saveContext()
    }
    
    // Doesn't use this function.
    func loadDataAsync(coreDataStack: CoreDataStack){
        println("loadDataAsync")
        
        fetchRequest = NSFetchRequest(entityName: "Exchange")
        
        asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest){
            [unowned self] (result: NSAsynchronousFetchResult!) -> Void in
            
            self.exchange = result.finalResult as [Exchange]
        }
        
        var error: NSError?
        let results = coreDataStack.context.executeRequest(asyncFetchRequest, error: &error)
        
        if let persistentStoreResults = results{
            
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func loadData(coreDataStack: CoreDataStack){
        println("loadData")
        var fetchRequest = NSFetchRequest(entityName: "Exchange")
        
        var error: NSError?
        
        let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error)
        
        if let object = results {
            exchange = object as [Exchange]
        }
    }
    
    func saveTime(coreDataStack: CoreDataStack){
        println("saveTime")
        
        var oldMultiplier: NSNumber! = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Time")
        var error: NSError? = nil
        
        let resultscount = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        
        if resultscount != 0 {
            
            var fetchError: NSError? = nil
            let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError)
            
            for object in results!{
                let cube = object as Time
                
                // save the old multiplier value before the time data gets deleted
                oldMultiplier = cube.multiplierUpdate
                coreDataStack.context.deleteObject(cube)
            }
            
            coreDataStack.saveContext()
        }
        
        let timeEntity = NSEntityDescription.entityForName("Time", inManagedObjectContext: coreDataStack.context)
        let time = Time(entity: timeEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        
        time.multiplierUpdate = oldMultiplier
        //println("\(latestParseTime)")
        time.lastUpdate = latestParseTime
        
        coreDataStack.saveContext()
    }
    
    func updateTime(coreDataStack: CoreDataStack, multiplier: NSNumber){
        println("updateTime")
        
        var oldLastUpdate: NSDate! = NSDate(timeIntervalSince1970: NSTimeInterval(0))
        println("\(oldLastUpdate)")
        
        let fetchRequest = NSFetchRequest(entityName: "Time")
        var fetchError: NSError? = nil
        let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError)
        
        for object in results!{
            let cube = object as Time
            
            // save lastUpdate in a variabel before it gets deleted
            oldLastUpdate = cube.lastUpdate
            coreDataStack.context.deleteObject(cube)
        }
        
        println("oldLastUpdate: \(oldLastUpdate)")
        
        coreDataStack.saveContext()
        
        let timeEntity = NSEntityDescription.entityForName("Time", inManagedObjectContext: coreDataStack.context)
        let time = Time(entity: timeEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        
        time.multiplierUpdate = multiplier
        time.lastUpdate = oldLastUpdate
        
        println("multi: \(time.multiplierUpdate), last: \(time.lastUpdate)")
        
        coreDataStack.saveContext()
    }
    
    // Return true if there is any time saved.
    func loadTime(coreDataStack: CoreDataStack) -> (hasTime: Bool, oldDate: NSDate){
        println("loadTime")
        
        let fetchRequest = NSFetchRequest(entityName: "Time")
        var error: NSError? = nil
        
        let resultsCount = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        
        var oldDate: NSDate?
        
        if resultsCount == 0 {
            return (false, NSDate())
        } else {
            var fetchError: NSError? = nil
            let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError)
            time = results as [Time]
            
            for object in results!{
                let cube = object as Time
                if compareTime(cube.lastUpdate, multiplier: cube.multiplierUpdate){
                    //println("Date is due, going to update!")
                    return (false, NSDate())
                }
                oldDate = cube.lastUpdate
            }
            
            println("Data is still ok to use!")
            return (true, oldDate!)
        }
    }
    
    func compareTime(dateOld: NSDate, multiplier: NSNumber) -> Bool{
        println("compareTime")
        
        let dateNow: NSDate = NSDate()
        let interval = dateNow.timeIntervalSinceDate(dateOld)
        
        var newTime = ( interval / 60 ) / 60
        
        println("dateOld: \(dateOld) dateNow: \(dateNow) interval: \(newTime) multiplier: \(multiplier)")
        
        
        // check if the interval of the times is over 24 * multiplier.
        if (Int(newTime) > (24 * multiplier.integerValue)){
            return true
        } else {
            return false
        }
    }
    
    func copyDictToArray(){
        println("copyDictToArray")
        
        for currency in currencyDict.keys{
            currencyArray.append(currency)
        }
    }
    
    func parseFromXml(coreDataStack: CoreDataStack){
        if(Reachability.isConnectedToNetwork()){ // Check if we have internet connection
            println("parseFromXml")
            
            var url: String = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
            var urlToSend: NSURL = NSURL(string: url)!
            
            // Parse the XML
            var parser = NSXMLParser(contentsOfURL: urlToSend)
            parser!.delegate = self
            
            var success: Bool = parser!.parse()
            
            if success {
                println("parse success!")
                currencyDict["EUR"] = 1.0
                copyDictToArray()
                saveData(coreDataStack)
                loadData(coreDataStack)
                saveTime(coreDataStack)
                loadTime(coreDataStack)
            } else {
                println("parse failure!")
            }
        } else {
            println("No internetz")
        }
    }
    
    
    // MARK - Parse
    
    func parser(parser: NSXMLParser!,didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
        
        var temp: String = ""
        
        if elementName == "Cube"{
            var currency =  attributeDict["currency"] as String!
            var rate =  attributeDict["rate"] as String!
            var time = attributeDict["time"] as String!
            
            if let terre = currency{
                temp = currency
            }
            
            if let terre2 = rate{
                var dbl = (rate as NSString).doubleValue // From String to NSString then to a Double.
                currencyDict[temp] = dbl
            }
            
            if let terre3 = time{
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                latestParseTime = dateFormatter.dateFromString(time)!
                
                // it is possible to use the right timezone, but this is a workaround.
                var newTime = latestParseTime.dateByAddingTimeInterval(3600*13)
                
                latestParseTime = newTime
                //println("After: \(newTime)")
            }
        }
    }
    
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        NSLog("failure error: %@", parseError)
    }
}