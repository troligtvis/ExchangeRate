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
        
        if currencyDict.count != 0 {
            println("From: \(currencyDict[fromCurrency])")
            println("To: \(currencyDict[toCurrency])")
        
            var textFieldValue = NSString(string: textField.text)
            var fromValue = textFieldValue.doubleValue
        
            var toValue = currencyDict[toCurrency]
        
            convertedValue.text = String(format:"%f", calculateRate(fromValue, toValue!))
        
        } else {
            
            var titleOnAlert = "Error!"
            var messageOnAlert = "There is no data"
            
            var alert = UIAlertController(title: titleOnAlert, message: messageOnAlert, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Cancel, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
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
        
        xmlParser.load()
        
        copyDictToArray()
        
        picker1.delegate = self
        picker1.dataSource = self
        picker1.selectRow(0, inComponent: 0, animated: true) // select default row.
        
        picker2.delegate = self
        picker2.dataSource = self
        picker2.selectRow(0, inComponent: 0, animated: true)
        
        if(currencyDict.count != 0){
            fromCurrency = currencyArray[0]
            toCurrency = currencyArray[0]
        } else {
            fromCurrency = "Empty"
            toCurrency = "Empty"
        }
        
        /*
        for var i = 0; i < currencyDict.count; ++i{
                //save(currencyArray[i], rate: currencyDict[currencyArray[i]]!)
            xmlParser.saveData(currencyArray[i], rate: currencyDict[currencyArray[i]]!)
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

