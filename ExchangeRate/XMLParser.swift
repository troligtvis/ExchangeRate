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
    
    var currency = [NSManagedObject]()
    
    var strXMLData:String = ""
    var currentElement:String = ""
    var currencyDict: [String : Double] = [:]
    
    func initXMLParser(){
        
        // Ha någont sorts 24h timer för att se om man måste hämta ny data. 
            // Annars hämta från core data.
        if(Reachability.isConnectedToNetwork()){
            var url: String = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
            var urlToSend: NSURL = NSURL(string: url)!
        
            // Parse the XML
            var parser = NSXMLParser(contentsOfURL: urlToSend)
            parser!.delegate = self
        
            // Start the event-driven parsing
            var success: Bool = parser!.parse()
            
            if success {
                println("parse success!")
                currencyDict["EUR"] = 1.0
            } else {
                println("parse failure!")
            }
        } else {
            println("No internetz!")
        }
    }
    
    func load(){
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "RateEntity")

        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            println("Results \(results.count)")
            for result in results as NSArray {
                currencyDict[result.valueForKey("currency")! as String] = result.valueForKey("rate")! as Double
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }

    func saveData(currency: String, rate: Double){
         let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        managedContext.deletedObjects // Delete all objects in the manageContext.
        
        let entity = NSEntityDescription.entityForName("RateEntity", inManagedObjectContext: managedContext)
        let currencyAndRate = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        currencyAndRate.setValue(rate, forKey: "rate")
        currencyAndRate.setValue(currency, forKey: "currency")
        
        var error: NSError?
        if managedContext.save(&error){
            println("Saved!")
        } else {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func parser(parser: NSXMLParser!,didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
        
        //println("didStartElemen: \(elementName)")
        
        var temp: String = ""
        
        if elementName == "Cube"{
            var currency =  attributeDict["currency"] as String!
            var rate =  attributeDict["rate"] as String!
            if let terre = currency{
                temp = currency
            } else {
                //println("apperently null")
            }
            
            if let terre2 = rate{
                var dbl = (rate as NSString).doubleValue // From String to NSString then to a Double.
                currencyDict[temp] = dbl
            } else {
                //println("apperently null")
            }
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        //println("didEndElement: \(elementName)")
        
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        //println("foundCharacter: \(string)")
    }
    
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        NSLog("failure error: %@", parseError)
    }
    
}