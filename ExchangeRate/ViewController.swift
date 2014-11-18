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
   
    var coreDataStack: CoreDataStack!
    
    var currencyDict: [String : Double] = [:]
    var currencyArray: [String] = []
    var xmlParser: XMLParser!
    var fromCurrency: Exchange!
    var toCurrency: Exchange!
    
    var time: [Time]! = []
    var exchange: [Exchange]! = []
    
    var fetchTimeRequest: NSFetchRequest!
    var asyncFetchTimeRequest: NSAsynchronousFetchRequest!
    var fetchRequest: NSFetchRequest!
    var asyncFetchRequest: NSAsynchronousFetchRequest!
    
    var timeStr: String = "N/A"
    
    @IBOutlet weak var bgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var convertedValue: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func refreshButton(sender: AnyObject) {
        //xmlParser.importXMLDataIfNeeded(coreDataStack, needReset: true)
        /*xmlParser.importTimeIfNeeded(coreDataStack, needUpdate: true)
        self.asyncFetchFromContext()
        Async.background{
            
            self.fetchTimeFromContext()
            }.main{
                self.picker1.reloadAllComponents()
                self.picker2.reloadAllComponents()
                
                
                self.timeLabel.text = self.timeStr
        }
        self.picker1.reloadAllComponents()
        self.picker2.reloadAllComponents()*/
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
                toValue = toCurrency.rate.doubleValue
            } else {
                toValue = exchange[0].rate.doubleValue
            }
            
            // Change to 2 decimals
            //let someDoubleFormat = ".2"
            convertedValue.text = String(format:"%.2f", calculateRate(fromValue, toValue))
            
        } else {
            var titleOnAlert = "Error!"
            var messageOnAlert = "There is no data."
            
            var alert = UIAlertController(title: titleOnAlert, message: messageOnAlert, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Cancel, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapped(sender: AnyObject) {
        textField.resignFirstResponder()
    }
    

    override func viewDidAppear(animated: Bool) {
        xmlParser = XMLParser()
    
        self.asyncFetchFromContext()
        
        let backgroundThread = Async.background {
            println("A: This is run on the \(qos_class_self().description) (expected \(qos_class_main().description))")
            
            self.fetchTimeFromContext()
        }
            
        let updateMainThread = backgroundThread.main {
            println("B: This is run on the \(qos_class_self().description) (expected \(qos_class_main().description)), after the previous block")
        
            self.picker1.delegate = self
            self.picker1.dataSource = self
            self.picker2.delegate = self
            self.picker2.dataSource = self
            
            self.picker1.reloadAllComponents()
            self.picker2.reloadAllComponents()
            
            self.timeLabel.text = self.timeStr
        }
        
        println("Först")
    
        timeLabel.text = timeStr
        
        
    }
    
    
    
    func fetchTimeFromContext(){
        fetchTimeRequest = NSFetchRequest(entityName: "Time")
        
        var error: NSError?
        let result = coreDataStack.context.executeFetchRequest(fetchTimeRequest,
            error: &error) as [Time]?
        
        if let myTime = result {
            println("asyncFetchTime: \(myTime.count)")
            timeStr = myTime[0].lastUpdate
        }
    }

    
    func asyncFetchFromContext(){
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
    
    func createPicker(picker: UIPickerView, pickerId: Int){
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(0, inComponent: 0, animated: true)
        
        if pickerId == 1 {
            fromCurrency = exchange[0]
        } else {
            toCurrency = exchange[0]
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
        return exchange.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return exchange[row].currency
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView.isEqual(picker1){ // Check if the right pickerviewn.
            fromCurrency = exchange[row]
        } else if pickerView.isEqual(picker2) {
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
            pickerLabel!.text = exchange[row].currency
        } else {
            pickerLabel!.text = "Empty"
        }

        
        
        return pickerLabel
    }
}

