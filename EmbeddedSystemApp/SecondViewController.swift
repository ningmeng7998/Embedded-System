//
//  SecondViewController.swift
//  EmbeddedSystemApp
//
//  Created by ning li on 11/9/18.
//  Copyright © 2018 ning li. All rights reserved.
//

import UIKit
import SwiftChart
import Charts
import FirebaseDatabase
import Alamofire
import SwiftyJSON


class SecondViewController: UIViewController {
    
    @IBOutlet weak var melLabel: UILabel!
    
    @IBOutlet weak var newYorkLabel: UILabel!
    
    @IBOutlet weak var londonLabel: UILabel!
    
    @IBAction func clearButton(_ sender: Any) {
        initialData()
    }
    
    @IBOutlet weak var chart: Chart!

    var ref: DatabaseReference?

    var series1 = ChartSeries([])
    var series2 = ChartSeries([])
    var series3 = ChartSeries([])

    override func viewDidLoad() {
        super.viewDidLoad()

        //set firebase reference
        ref = Database.database().reference()

        createCharts()
    }
    
    func addLegend(color1: UIColor, color2: UIColor, color3: UIColor){
        let redFrame = CGRect(x: 30, y: 455, width: 20, height: 20)
        let redSquare = UIView(frame: redFrame)
        redSquare.backgroundColor = color1
        
        let greenFrame = CGRect(x: 140, y: 455, width: 20, height: 20)
        let greenSquare = UIView(frame: greenFrame)
        greenSquare.backgroundColor = color2
        
        let blueFrame = CGRect(x: 250, y: 455, width: 20, height: 20)
        let blueSquare = UIView(frame: blueFrame)
        blueSquare.backgroundColor = color3
        
        view.addSubview(blueSquare)
        view.addSubview(redSquare)
        view.addSubview(greenSquare)
    }
    

   
    func changeColor(){
        self.ref?.child("Colors").observe(.value, with: { (snapshot) in
            print(snapshot)
            let colorDictionary = snapshot.value as! Dictionary<String,Any>
            let color1 = colorDictionary["Color1"] as? Dictionary<String,Int>
            let color2 = colorDictionary["Color2"] as? Dictionary<String,Int>
            let color3 = colorDictionary["Color3"] as? Dictionary<String,Int>

            print("RGBColor = \(String(describing: color1))")
            if let color1 = color1, let color2 = color2, let color3 = color3{
                
                let c1 = UIColor(red: color1["R"]!, green: color1["G"]!, blue: color1["B"]!)
                let c2 = UIColor(red: color2["R"]!, green: color2["G"]!, blue: color2["B"]!)
                let c3 = UIColor(red: color3["R"]!, green: color3["G"]!, blue: color3["B"]!)
                

                self.series1.color = c1
                self.series2.color = c2
                self.series3.color = c3
                self.addLegend(color1: c1, color2: c2, color3: c3)

                self.chart.removeAllSeries()
                self.chart.add([self.series1,self.series2,self.series3])

            }

        })
    }
    
    func createRandomColor() ->UIColor{
        let red = CGFloat(arc4random_uniform(255)) / CGFloat(255)
        let green = CGFloat(arc4random_uniform(255)) / CGFloat(255)
        let blue = CGFloat(arc4random_uniform(255)) / CGFloat(255)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
    func createCharts(){
        ref?.child("Cities").observeSingleEvent(of:.value, with: { (snapshot) in
            let data = snapshot.value as? Dictionary<String,Any>
            if let acturalData = data{
                print("got all data \(acturalData)")
               
                let tokyos = self.extractDoublesFromDictionary(key: "Tokyo", source: acturalData)
                self.series1 = ChartSeries(tokyos)
                self.series1.area = true
               
                let melDoubles = self.extractDoublesFromDictionary(key: "Melbourne", source: acturalData)
                self.series2 = ChartSeries(melDoubles)
                self.series2.area = true

                let londonDoubles = self.extractDoublesFromDictionary(key: "London", source: acturalData)
                self.series3 = ChartSeries(londonDoubles)
                self.series3.area = true

                self.changeColor()
            }
        })
    }

    func extractDoublesFromDictionary(key:String,source:Dictionary<String,Any>)->[Double]{
        let dictionary = source[key] as! Dictionary<String,Double>
        
        var keys = Array(dictionary.keys)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        keys.sort(by: { (a, b) -> Bool in
            let date1 = formatter.date(from: a)
            let date2 = formatter.date(from: b)

            return date1!<date2!
        })

        var results:[Double] = []
        for (index,element) in keys.enumerated(){
            results.append(dictionary[element] ?? 0)

        }
        print("all keys \(keys)")
        print("double array = \(results)")
        return results
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initialData(){
        var dict1 = [String: Double]()
        dict1["R"] = 255
        dict1["G"] = 255
        dict1["B"] = 255
        ref?.child("Colors").child("Color1").setValue(dict1)
        
        var dict2 = [String: Double]()
        dict2["R"] = 255
        dict2["G"] = 255
        dict2["B"] = 255
        ref?.child("Colors").child("Color2").setValue(dict2)
        
        var dict3 = [String: Double]()
        dict3["R"] = 255
        dict3["G"] = 255
        dict3["B"] = 255
        ref?.child("Colors").child("Color3").setValue(dict3)
    }
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
   
}

