//
//  ViewController.swift
//  ExchangeRate
//
//  Created by Kj Drougge on 2014-11-10.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate {
    
    //var currencyMO = [NSManagedObject]()
    
    var currencyDict: [String : Double] = [:]
    var currencyArray: [String] = []
    var xmlParser: XMLParser!
    var fromCurrency: String!
    var toCurrency: String!
    
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var convertedValue: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func convertButton(sender: AnyObject) {
        println("From: \(currencyDict[fromCurrency])")
        println("To: \(currencyDict[toCurrency])")
        
        var textFieldValue = NSString(string: textField.text)
        var fromValue = textFieldValue.doubleValue
        
        var toValue = currencyDict[toCurrency]
        
        
        convertedValue.text = String(format:"%f", calculateRate(fromValue, toValue!))
        
        
        
        // Load from the DB
        // load()
    }
    
    @IBAction func tapped(sender: AnyObject) {
        textField.resignFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        xmlParser = XMLParser()
        xmlParser.initXMLParser()
        currencyDict = xmlParser.currencyDict
        copyDictToArray()
        
        picker1.delegate = self
        picker1.dataSource = self
        picker1.selectRow(0, inComponent: 0, animated: true) // select default row.
        fromCurrency = currencyArray[0]
        
        picker2.delegate = self
        picker2.dataSource = self
        picker2.selectRow(0, inComponent: 0, animated: true)
        toCurrency = currencyArray[0]
        
        /*
        for var i = 0; i < currencyDict.count; ++i{
                save(currencyArray[i], rate: currencyDict[currencyArray[i]]!)
        }
        */
    }
    
    func copyDictToArray(){
        println("CurrencyDict: \(currencyDict.count)")
        for currency in currencyDict.keys{
            currencyArray.append(currency)
        }
        //println(currencyArray)
    }
    
    func load(){
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "RateEntity")
        //fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        /*  // find all the attribute keys in the entity
        let entity = NSEntityDescription.entityForName("RateEntity", inManagedObjectContext: managedContext)
        let attributes: NSDictionary = entity!.attributesByName
        var keys = attributes.allKeys
        */
        
        
        /*
        for attribute in attributes{
            
            println("Test: \(attribute.key)")
        }*/
        
        if let results = fetchedResults {
            //currencyMO = results
            println("Results \(results.count)")
            for result in results as NSArray {
                
                //println(result)
                println(result.valueForKey("currency")!)
                //currencyDict[result.valueForKey("currency")! as String] = result.valueForKey("rate")! as? Double
                println(result.valueForKey("rate")!)
            }
            
            //currencyDict = fetchRequest.dictionaryWithValuesForKeys(["currency" : "rate"])
            
            //println("currencyMO: \(currencyMO)")
    
        
            
            
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        //fetchedResults?.removeAll(keepCapacity: false)
    }
    
    func save(currency: String, rate: Double){
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        managedContext.deletedObjects // Delete all objects in the manageContext.
        
        var i = 0
        let entity = NSEntityDescription.entityForName("RateEntity", inManagedObjectContext: managedContext)
        let currencyAndRate = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
        //for (currency, rate) in currencyDict{
            currencyAndRate.setValue(rate, forKey: "rate")
            currencyAndRate.setValue(currency, forKey: "currency")
            
            
    
            //println(currencyAndRate.valueForKey("rate"))
            //println(currencyAndRate.valueForKey("currency"))
            
            
            var error: NSError?
            if managedContext.save(&error){
                println("Saved!")
            } else {
                println("Could not save \(error), \(error?.userInfo)")
            }

            
            
            
           //currencyMO.append(currencyAndRate)
        //}
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Delegates and datasources
    //MARK: Data Sources
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return currencyArray[row]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView.isEqual(picker1){ // Check if the right pickerviewn.
            fromCurrency = currencyArray[row]
        } else if pickerView.isEqual(picker2) {
            toCurrency = currencyArray[row]
        }
    }
    
    //size the components of the UIPickerView
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }
}

