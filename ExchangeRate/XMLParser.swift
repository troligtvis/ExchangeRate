//
//  XMLParser.swift
//  ExchangeRate
//
//  Created by Kj Drougge on 2014-11-10.
//  Copyright (c) 2014 kj. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class XMLParser:NSObject, NSXMLParserDelegate {
    
    var currencyDict: [String : Double] = [:]
    var currencyArray: [String] = []
    
    var latestParseTime: String!
    
    
    func startXMLParser(coreDataStack: CoreDataStack){
        if(Reachability.isConnectedToNetwork()){ // Check if we have internet connection
            var url: String = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
            var urlToSend: NSURL = NSURL(string: url)!
            
            //currencyDict.removeAll()
            
            // Parse the XML
            var parser = NSXMLParser(contentsOfURL: urlToSend)
            parser!.delegate = self
            
            // Start the event-driven parsing
        
            
            var success: Bool = parser!.parse()
            
            if success {
                println("parse success!")
                currencyDict["EUR"] = 1.0
                self.copyDictToArray()
                self.importXMLDataIfNeeded(coreDataStack, needReset: true)
                self.asyncFetchFromContext(coreDataStack)
                //self.importTimeIfNeeded(coreDataStack, needUpdate: true)
            } else {
                println("parse failure!")
            }
            // }
            
        } else {
            println("No internetz!")
        }
    }
    
    func copyDictToArray(){
        //currencyArray.removeAll(keepCapacity: false)
        //currencyArray = []
        
        //currencyArray.removeAll()
        
        for currency in currencyDict.keys{
            currencyArray.append(currency)
        }
    }
    
    func importTimeIfNeeded(coreDataStack: CoreDataStack, needUpdate: Bool){
        println("importTimeIfNeeded!")
        let fetchRequest = NSFetchRequest(entityName: "Time")
        var error: NSError? = nil
        
        let results = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        println("importTimeIfNeeder: \(results)")
        
        if results == 0 || needUpdate{
            println("importTimeIfNeeded: \(results)")
            var fetchError: NSError? = nil
            
            let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError)
            
            if !needUpdate{
                
                for object in results!{
                    let cube = object as Time
                    coreDataStack.context.deleteObject(cube)
                }
                
                coreDataStack.saveContext()
                
                self.startXMLParser(coreDataStack)
                self.importTime(coreDataStack)
            } else {
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateNow: String! = dateFormatter.stringFromDate(NSDate())
                latestParseTime = dateNow
                self.startXMLParser(coreDataStack)
                
                for object in results!{
                    let cube = object as Time
                    coreDataStack.context.deleteObject(cube)
                }
                
                coreDataStack.saveContext()
                
                self.importTime(coreDataStack)
            }
        } else {
            var fetchError: NSError? = nil
            let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError)
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateNow: String! = dateFormatter.stringFromDate(NSDate())
            
            for object in results!{
                println("else: \(results!.count)")
                
                let cube = object as Time
                println("Cube.lastUpdate: \(cube.lastUpdate)")
                if !(cube.lastUpdate == dateNow){
                    println("Date is due, going to update!")
                    
                    self.startXMLParser(coreDataStack)
                    self.importTime(coreDataStack)
                    self.asyncFetchFromContext(coreDataStack)
                } else {
                    self.asyncFetchFromContext(coreDataStack)
                    println("Samma datum")
                }
            }
        }
    }
    
    func importTime(coreDataStack: CoreDataStack){
        let timeEntity = NSEntityDescription.entityForName("Time", inManagedObjectContext: coreDataStack.context)
        let time = Time(entity: timeEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        //time.lastUpdate = latestParseTime
        println("latestParseTime: \(latestParseTime)")
        
        
        coreDataStack.saveContext()
    }
    
    func importXMLDataIfNeeded(coreDataStack: CoreDataStack, needReset: Bool){
        println("importXMLDataIfNeeded!")
        let fetchRequest = NSFetchRequest(entityName: "Exchange")
        var error: NSError? = nil
        
        let results = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        println("importXMLDataIfNeeder: \(results)")
        
        if results == 0 || needReset{
            //Async.background {
                println("This run, thats it")
                println("importXMLDataIfNeeded: \(results)")
                var fetchError: NSError? = nil
                
                let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError)
                
                for object in results!{
                    let cube = object as Exchange
                    coreDataStack.context.deleteObject(cube)
                }
                
                coreDataStack.saveContext()
                self.importXMLData(coreDataStack)
                
                println("DONE?")
            //}
        }
    }
    
    func importXMLData(coreDataStack: CoreDataStack){
        //  println(currencyDict.count)
        for var i = 0; i < currencyDict.count; ++i{
            let exchangeEntity = NSEntityDescription.entityForName("Exchange", inManagedObjectContext: coreDataStack.context)
            
            let exchange = Exchange(entity: exchangeEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            
            exchange.currency = currencyArray[i]
            exchange.rate = currencyDict[currencyArray[i]]!
        }
        
        coreDataStack.saveContext()
    }
    
    
    var fetchRequest: NSFetchRequest!
    var asyncFetchRequest: NSAsynchronousFetchRequest!
    var exchange: [Exchange]! = []
    
    func asyncFetchFromContext(coreDataStack: CoreDataStack){
        fetchRequest = NSFetchRequest(entityName: "Exchange")
        
        asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest){
            [unowned self] (result: NSAsynchronousFetchResult!) -> Void in
            
            self.exchange = result.finalResult as [Exchange]
            //self.picker1.reloadAllComponents()
            //self.picker2.reloadAllComponents()
        }
        
        var error: NSError?
        let results = coreDataStack.context.executeRequest(asyncFetchRequest, error: &error)
        
        if let persistentStoreResults = results{
            
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }

    
    
    func compareDate(){
        
    }
    
    
    // MARK - Parse
    
    func parser(parser: NSXMLParser!,didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
        
        var temp: String = ""
        
        if elementName == "Cube"{
            var currency =  attributeDict["currency"] as String!
            var rate =  attributeDict["rate"] as String!
            if let terre = currency{
                temp = currency
            }
            
            if let terre2 = rate{
                var dbl = (rate as NSString).doubleValue // From String to NSString then to a Double.
                currencyDict[temp] = dbl
            }
            
            var time = attributeDict["time"] as String!
            if let terre3 = time{
                latestParseTime = time
            }
        }
    }
    
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        NSLog("failure error: %@", parseError)
    }
}