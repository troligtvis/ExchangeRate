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
    
    var xmlParser: XMLParserTest!
    
    var fromCurrency: Exchange!
    var toCurrency: Exchange!
    
    var time: [Time]!
    var exchange: [Exchange]!
    
    var timeStr: String = "N/A"
    
    @IBOutlet weak var bgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var convertedValue: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func refreshButton(sender: AnyObject) {
        var titleOnAlert = "Update"
        var messageOnAlert = "When do you want the updates?"
        
        var alert = UIAlertController(title: titleOnAlert, message: messageOnAlert, preferredStyle: UIAlertControllerStyle.Alert)
        
        let oneAction = UIAlertAction(title: "24hr", style: .Default, handler: changeUpdateTime)
        let twoAction = UIAlertAction(title: "48hr", style: .Default, handler: changeUpdateTime)
        let threeAction = UIAlertAction(title: "78hr", style: .Default, handler: changeUpdateTime)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        alert.addAction(oneAction)
        alert.addAction(twoAction)
        alert.addAction(threeAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    

    func changeUpdateTime(alert: UIAlertAction!){
        Async.background{
            switch(alert.title){
                case "24hr":
                    self.xmlParser.updateTime(self.coreDataStack, multiplier: 1)
                    break;
                case "48hr":
                    self.xmlParser.updateTime(self.coreDataStack, multiplier: 2)
                    break;
                case "78hr":
                    self.xmlParser.updateTime(self.coreDataStack, multiplier: 3)
                    break;
            default:
                println("Somethings wong")
                break;
            }
        }
        
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

        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        Async.background {
            //println("A: This is run on the \(qos_class_self().description) (expected \(qos_class_main().description))")
            
            self.xmlParser.checkTime(self.coreDataStack)
            
            }.main {
                //println("B: This is run on the \(qos_class_self().description) (expected \(qos_class_main().description)), after the previous block")
                
                self.exchange = self.xmlParser.exchange
                self.time = self.xmlParser.time
                
                self.picker1.delegate = self
                self.picker1.dataSource = self
                self.picker2.delegate = self
                self.picker2.dataSource = self
                
                self.picker1.reloadAllComponents()
                self.picker2.reloadAllComponents()
                
                
                let dateParse: String! = dateFormatter.stringFromDate(self.time[0].lastUpdate)
                self.timeLabel.text = dateParse //self.timeStr
        }
        
        timeLabel.text = timeStr
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
        if exchange.count != 0{
            return exchange[row].currency
        } else{
            return "Empty"
        }
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        if exchange.count != 0{
            if pickerView.isEqual(picker1){ // Check if the right pickerviewn.
                
                fromCurrency = exchange[row]
            } else if pickerView.isEqual(picker2) {
                toCurrency = exchange[row]
            }
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

