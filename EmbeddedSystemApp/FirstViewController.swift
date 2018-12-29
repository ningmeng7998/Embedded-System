//
//  FirstViewController.swift
//  EmbeddedSystemApp
//
//  Created by ning li on 11/9/18.
//  Copyright © 2018 ning li. All rights reserved.
//

import UIKit
import Charts
import FirebaseDatabase


class FirstViewController: UIViewController {

    @IBOutlet weak var scatterChartView: ScatterChartView!
    
    var ref: DatabaseReference?
    
    
    @IBAction func selectedSegement(_ sender: UISegmentedControl) {
        
        //Draw charts according to different choices
        if sender.selectedSegmentIndex == 0{
            setScatterValues(label: "Seconds")
        }else if sender.selectedSegmentIndex == 1{
            setScatterValues(label: "Minutes")
        }else{
            setScatterValues(label: "Hours")
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setScatterValues(label: "Seconds")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setScatterValues(label: String){
        //Get the value of CurrentTemp node
        ref?.child("CurrentTemp").observe(.value, with: { (snapshot) in
            
            let data = snapshot.value as? Dictionary<String,Any>
            if let acturalData = data{

                print("actural data = \(type(of: acturalData))")
                print("acutral data = \(acturalData)")
                
                let melDic = acturalData[label] as! Dictionary<String,Double>
                print("melDic \(melDic)")
                let keys = Array(melDic.keys)
                
                //Sort the keys
                let sortedKeys = self.sortKeys(keys)
                
                //Put the values into chart entry to draw the chart
                let chartEntries = self.getLastSixItemsInArray(sortedKeys, melDic)
                print("final results : \(chartEntries)")
                
                let set1 = ScatterChartDataSet(values: chartEntries, label: label)
                let chartData = ScatterChartData(dataSets: [set1])
                self.scatterChartView.data = chartData
            }
        })
    }
    

    func sortKeys(_ keys:[String])->[String]{
        var sortableKeys = keys
        sortableKeys.sort(by: { (a, b) -> Bool in
            let key1 = Int(a)
            let key2 = Int(b)
            return key1! < key2!
        })
        return sortableKeys
    }
    
    //Get the current six values of the temperature node
    func getLastSixItemsInArray(_ keys:[String],_ dictionary:Dictionary<String,Double>)->[ChartDataEntry]{
        let startFromHere = keys.count - 6
        var lastSixKeys:[String] = []
        for (index,element) in keys.enumerated(){
            
            if index < startFromHere {
                continue
            }
            lastSixKeys.append(element)
        }
        
        var results:[ChartDataEntry] = []
        
        for (index,element) in lastSixKeys.enumerated(){
            let entry = ChartDataEntry(x: Double(index), y: dictionary[keys[index]] as! Double)
            results.append(entry)
        }
        return results
    }
}
