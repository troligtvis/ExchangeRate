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
    
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var convertedValue: UILabel!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet var mainView: UIView!
    
    @IBAction func refreshButton(sender: AnyObject) {
        
    }
    
    @IBAction func convertButton(sender: AnyObject) {
        
        if currencyDict.count != 0 {
            println("From: \(currencyDict[fromCurrency])")
            println("To: \(currencyDict[toCurrency])")
            
            var textFieldValueString = NSString(string: textField.text)
            var textFieldValueDouble = textFieldValueString.doubleValue
            var fromValue: Double = textFieldValueDouble / currencyDict[fromCurrency]!
            var toValue = currencyDict[toCurrency]
            
            convertedValue.text = String(format:"%f", calculateRate(fromValue, toValue!))
            
        } else {
            
            var titleOnAlert = "Error!"
            var messageOnAlert = "There is no data."
            
            var alert = UIAlertController(title: titleOnAlert, message: messageOnAlert, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Cancel, handler:refresh))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func refresh(alertView: UIAlertAction!){
        // Refresha här !
        xmlParser.load()
        
        currencyDict = xmlParser.currencyDict
        copyDictToArray()
        
        picker1.reloadAllComponents()
        picker2.reloadAllComponents()
        
        createPicker(picker1, pickerId: 1)
        createPicker(picker2, pickerId: 2)
        
        println("refresh")
    }
    
    @IBAction func tapped(sender: AnyObject) {
        textField.resignFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        xmlParser = XMLParser()
        
        //xmlParser.startXMLParser()
        
        //xmlParser.load()
        
        xmlParser.loadTime()
        
        currencyDict = xmlParser.currencyDict
        
        copyDictToArray()
        
        if(currencyDict.count != 0){
            
            //picker1.delegate = self
            //picker1.dataSource = self
            //picker1.selectRow(0, inComponent: 0, animated: true) // select default row.
            createPicker(picker1, pickerId: 1)
            //fromCurrency = currencyArray[0]
            
            
            //picker2.delegate = self
            //picker2.dataSource = self
            //picker2.selectRow(0, inComponent: 0, animated: true)
            createPicker(picker2, pickerId: 2)
            //toCurrency = currencyArray[0]
        } else {
            fromCurrency = "Empty"
            toCurrency = "Empty"
            //currencyArray[0] = "Empty"
        }
        
       xmlParser.loadTime()
        
        /*
        for var i = 0; i < currencyDict.count; ++i{
                //save(currencyArray[i], rate: currencyDict[currencyArray[i]]!)
            xmlParser.saveData(currencyArray[i], rate: currencyDict[currencyArray[i]]!)
        }
        */
        
    }
    
    func createPicker(picker: UIPickerView, pickerId: Int){
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(0, inComponent: 0, animated: true)
        
        if pickerId == 1 {
            fromCurrency = currencyArray[0]
        } else {
            toCurrency = currencyArray[0]
        }
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
    
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            
            let hue = CGFloat(row)/CGFloat(currencyArray.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
            pickerLabel.textAlignment = .Center
        }
        
        //let titleData = currencyArray[row]
        //let myTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName:UIColor.blackColor()])
        //pickerLabel!.attributedText = myTitle
        
        pickerLabel!.text = currencyArray[row]
        
        return pickerLabel
    }
    
    
    //size the components of the UIPickerView
    /*
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }
    */

}

