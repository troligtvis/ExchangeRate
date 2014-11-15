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
            
            // Parse the XML
            var parser = NSXMLParser(contentsOfURL: urlToSend)
            parser!.delegate = self
            
            // Start the event-driven parsing
            var success: Bool = parser!.parse()
            
            if success {
                println("parse success!")
                self.copyDictToArray()
                importXMLData(coreDataStack)
                //importXMLDataIfNeeded(coreDataStack, needReset: true)
                //clearTimeIfNeeded(coreDataStack, needReset: false)
            } else {
                println("parse failure!")
            }
        } else {
            println("No internetz!")
        }
    }
    
    func copyDictToArray(){
        //currencyArray.removeAll(keepCapacity: false)
        //currencyArray = []
        for currency in currencyDict.keys{
            currencyArray.append(currency)
        }
    }
    
        
       
    func importXMLDataIfNeeded(coreDataStack: CoreDataStack, needReset: Bool){
        println("importXMLDataIfNeeded!")
        let fetchRequest = NSFetchRequest(entityName: "Exchange")
        var error: NSError? = nil
        
        let results = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        println("importXMLDataIfNeeder: \(results)")
        
        if results == 0 || needReset{
            println("importXMLDataIfNeeded: \(results)")
            var fetchError: NSError? = nil
            
            let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError)
            
            for object in results!{
                let cube = object as Exchange
                coreDataStack.context.deleteObject(cube)
            }
            
            coreDataStack.saveContext()
            self.startXMLParser(coreDataStack)
        } else {
            self.importXMLData(coreDataStack)
        }
    }
    
    func importXMLData(coreDataStack: CoreDataStack){
        //  println(currencyDict.count)
        for var i = 0; i < currencyDict.count; ++i{
            let exchangeEntity = NSEntityDescription.entityForName("Exchange", inManagedObjectContext: coreDataStack.context)
            
            let exchange = Exchange(entity: exchangeEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            
            exchange.currency = currencyArray[i]
            exchange.rate = currencyDict[currencyArray[i]]!
            //println("\(currencyArray[i]) andRate: \(currencyDict[currencyArray[i]])")
        }
        
        /*
        let timeEntity = NSEntityDescription.entityForName("Time", inManagedObjectContext: coreDataStack.context)
        let time = Time(entity: timeEntity!, insertIntoManagedObjectContext: coreDataStack.context)
        time.lastUpdate = latestParseTime
        */
        
        //println(currencyDict)
        //println(currencyArray)
        coreDataStack.saveContext()
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