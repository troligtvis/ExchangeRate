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
   
    var managedContext: NSManagedObjectContext!
    
    var coreDataStack: CoreDataStack!
    var exchange: [Exchange]! = []
    
    var fetchRequest: NSFetchRequest!
    var asyncFetchRequest: NSAsynchronousFetchRequest!
    
    var currencyDict: [String : Double] = [:]
    var currencyArray: [String] = []
    var xmlParser: XMLParser!
    var fromCurrency: Exchange! //String!
    var toCurrency: Exchange! //String!
    
    
    
    @IBOutlet weak var bgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var convertedValue: UILabel!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet var mainView: UIView!
    
    @IBAction func refreshButton(sender: AnyObject) {
        xmlParser.startXMLParser(coreDataStack)
        
        
        
        
        currencyDict = xmlParser.currencyDict
        copyDictToArray()
        
        timeLabel.text = xmlParser.latestParseTime
        
        picker1.reloadAllComponents()
        picker2.reloadAllComponents()
        
        createPicker(picker1, pickerId: 1)
        createPicker(picker2, pickerId: 2)
    }
    
    @IBAction func convertButton(sender: AnyObject) {
        
        if exchange.count != 0 {
            var textFieldValueString = NSString(string: textField.text)
            var textFieldValueDouble = textFieldValueString.doubleValue
        
            var fromValue: Double!
            var toValue: Double!
            
            if let from = fromCurrency{
                fromValue = textFieldValueDouble / fromCurrency.rate.doubleValue
            } else {
                fromValue = textFieldValueDouble / exchange[0].rate.doubleValue
            }
            
            if let to = toCurrency {
                toValue = toCurrency.rate.doubleValue // currencyDict[toCurrency]
            } else {
                toValue = exchange[0].rate.doubleValue
            }
            
            convertedValue.text = String(format:"%f", calculateRate(fromValue, toValue))
            
        } else {
            var titleOnAlert = "Error!"
            var messageOnAlert = "There is no data."
            
            var alert = UIAlertController(title: titleOnAlert, message: messageOnAlert, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Cancel, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func refresh(alertView: UIAlertAction!){
        println("refresh")
    }
    
    @IBAction func tapped(sender: AnyObject) {
        textField.resignFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        picker1.delegate = self
        picker1.dataSource = self
        picker2.delegate = self
        picker2.dataSource = self

        asyncFetchFromContext()
    }
    
    func asyncFetchFromContext(){
        fetchRequest = NSFetchRequest(entityName: "Exchange")
        
        asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest){
            [unowned self] (result: NSAsynchronousFetchResult!) -> Void in
            
            self.exchange = result.finalResult as [Exchange]
            self.picker1.reloadAllComponents()
            self.picker2.reloadAllComponents()
        }
        
        var error: NSError?
        let results = coreDataStack.context.executeRequest(asyncFetchRequest, error: &error)
        
        if let persistentStoreResults = results{
    
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func createPicker(picker: UIPickerView, pickerId: Int){
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(0, inComponent: 0, animated: true)
        
        if pickerId == 1 {
            //fromCurrency = currencyArray[0]
            fromCurrency = exchange[0]
        } else {
            //toCurrency = currencyArray[0]
            toCurrency = exchange[0]
        }
    }
    
    func copyDictToArray(){
        println("CurrencyDict: \(currencyDict.count)")
        for currency in currencyDict.keys{
            currencyArray.append(currency)
        }
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
        //return currencyArray.count
        return exchange.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        //return currencyArray[row]
        return exchange[row].currency
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView.isEqual(picker1){ // Check if the right pickerviewn.
            //fromCurrency = currencyArray[row]
            fromCurrency = exchange[row]
        } else if pickerView.isEqual(picker2) {
            //toCurrency = currencyArray[row]
            toCurrency = exchange[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as UILabel!
        
        if view == nil { //if no label there yet
            pickerLabel = UILabel()
            
            let hue = CGFloat(row)/CGFloat(exchange.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
            pickerLabel.textAlignment = .Center
        }

        pickerLabel!.text = exchange[row].currency //currencyArray[row]
        
        return pickerLabel
    }
}

