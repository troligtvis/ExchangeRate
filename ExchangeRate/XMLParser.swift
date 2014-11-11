//
//  XMLParser.swift
//  ExchangeRate
//
//  Created by Kj Drougge on 2014-11-10.
//  Copyright (c) 2014 kj. All rights reserved.
//

import Foundation
import CoreData

class XMLParser:NSObject, NSXMLParserDelegate{
    
    var currency = [NSManagedObject]()
    
    var strXMLData:String = ""
    var currentElement:String = ""
    var currencyDict: [String : Double] = [:]
    
    func initXMLParser(){
        
        // Ha någont sorts 24h timer för att se om man måste hämta ny data. 
            // Annars hämta från core data.
        
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
            //save()
            
        } else {
            println("parse failure!")
        }
    }
    
    func save(){
        var names = [String]()
        names.append("")
    
        for currency in currencyDict.keys{
            //currencyArray.append(currency)
            
        }
    }
    
    func parser(parser: NSXMLParser!,didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
        currentElement=elementName;
        var temp: String = ""
        
        if elementName == "Cube"{
            var currency =  attributeDict["currency"] as String!
            var rate =  attributeDict["rate"] as String!
            if let terre = currency{
                //println("Currency: \(terre)")
                //passName = true
                temp = currency
            } else {
                //println("apperently null")
            }
            
            if let terre2 = rate{
                var dbl = (rate as NSString).doubleValue // From String to NSString then to a Double.
                //println("Rate: \(dbl)")
                //passName = true
                currencyDict[temp] = dbl
            } else {
                //println("apperently null")
            }
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        currentElement="";
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
    }
    
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        NSLog("failure error: %@", parseError)
    }
    
}