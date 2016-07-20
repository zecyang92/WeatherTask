//
//  ViewController.swift
//  WeatherTask
//
//  Created by zec on 5/11/16.
//  Copyright © 2016 RJT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var weatherArr: [Dictionary<String, AnyObject>] = []
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var visibility: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var cloudCover: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let loading = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loading.mode = MBProgressHUDMode.Indeterminate
        loading.label.text = "Loading"
        loading.label.textColor = UIColor.whiteColor()
        self.apiCallForWeatherData()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//MARK: Downloading data and XMLParsing 
extension ViewController {
    func apiCallForWeatherData() {
        let url = NSURL(string: "http://www.raywenderlich.com/demos/weather_sample/weather.php?format=xml")
        NSURLSession.sharedSession().dataTaskWithURL(url!) { (dat, response, error) -> Void in
            if error == nil {
                do {
                    let datastring = String(data: dat!, encoding: NSUTF8StringEncoding)
                    let nsdict = try XMLReader.dictionaryForXMLString(datastring!)
                    // future days' weather
                    self.weatherArr = nsdict["data"]!["weather"] as! [Dictionary<String, AnyObject>]
                    // today's weather
                    let current = nsdict["data"]!["current_condition"] as! Dictionary<String, AnyObject>
                    self.updateCurrentWeather(current)
                }
                catch {
                    print("error:\(error)")
                }
            }
            }.resume()
    }
    // update Today's weather
    func updateCurrentWeather(current: Dictionary<String, AnyObject>){
        // icon
        let imgUrl = current["weatherIconUrl"]!["value"] as! String
        self.icon.layer.cornerRadius = self.icon.frame.size.width / 2.0
        self.icon.clipsToBounds = true
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, {() -> Void in
            let data = NSData(contentsOfURL: NSURL(string: imgUrl)!)
            if (data != nil) {
                dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                    self.icon.image = UIImage(data: data!)
                })
            }
        })
        // detail
        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.temp.text = "\(current["temp_C"]!) °C / \(current["temp_F"]!)°F"
            self.desc.text = current["weatherDesc"]!["value"] as? String
            self.time.text = "Today \(current["observation_time"]!)"
            self.humidity.text = "Humidity: \(current["humidity"]!)%"
            self.pressure.text = "Pressure: \(current["pressure"]!)"
            self.visibility.text = "Visibility: \(current["visibility"]!) miles"
            self.cloudCover.text = "Cloudcover: \(current["cloudcover"]!)%"
            self.wind.text = "Wind: \(current["winddir16Point"]!) \(current["windspeedKmph"]!) kmph"
            self.tblView.reloadData()
        })
    }
}

//MARK: TableView Datasource and Delegate methods
extension ViewController {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return weatherArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CustomTableViewCell
        let weather = weatherArr[indexPath.row]
        
        // weather description
        cell.date.text = "\(weather["date"]!)"
        cell.desc.text = weather["weatherDesc"]!["value"] as? String
        cell.temp.text = "\(weather["tempMinC"]!) - \(weather["tempMaxC"]!) °C / \(weather["tempMinF"]!) - \(weather["tempMaxF"]!)°F"
        
        // icon
        let imgUrl = weather["weatherIconUrl"]!["value"] as! String
        cell.imgView.layer.cornerRadius = cell.imgView.frame.size.width / 2.0
        cell.imgView.clipsToBounds = true
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, {() -> Void in
            let data = NSData(contentsOfURL: NSURL(string: imgUrl)!)
            if (data != nil) {
                dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                    cell.imgView.image = UIImage(data: data!)
                })
            }
        })
        return cell
    }
}

