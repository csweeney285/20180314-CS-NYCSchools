//
//  SATViewController.swift
//  20180314-CS-NYCSchools
//
//  Created by Conor Sweeney on 3/14/18.
//  Copyright © 2018 Conor Sweeney. All rights reserved.
//

import UIKit

class SATViewController: UIViewController {
    var spinner: UIActivityIndicatorView!

    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var testTakerLabel: UILabel!
    @IBOutlet weak var readingLabel: UILabel!
    @IBOutlet weak var mathLabel: UILabel!
    @IBOutlet weak var writingLabel: UILabel!
    
    @IBAction func closeButtonPress(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView()  {
        //add spinner
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.frame = CGRect(x: self.view.center.x, y:self.view.center.y, width: 20.0, height: 20.0)
        spinner.startAnimating()
        self.view.addSubview(spinner)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSATData(schoolName: String) {
        let schoolName = "\""+schoolName.uppercased()+"\""
        DispatchQueue.global(qos: .background).async {
            //format sql api query where the data has the same school name as the selected school
            guard let url = URL(string:"https://data.cityofnewyork.us/resource/734v-jeq5.json?$where=school_name%20like%20"+schoolName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!) else{
                return
            }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    //unable to download school data
                    //remove spinner
                    self.spinner.removeFromSuperview()
                    //log error
                    print("Error: \(String(describing: error))")
                    //pop alert to allow user to attempt to reload the data
                    return
                }
                //I considered using the decodable to parse the json but it seemed over the top
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                print(json as Any)
                if let schoolInfoArray = json as? [Dictionary<String,String>] {
                    if schoolInfoArray.count == 0{
                        return
                    }
                    let schoolInfoDict = schoolInfoArray[0]
                    //dispatch to main thread to remove spinner and update the header
                    DispatchQueue.main.async {
                        self.spinner.removeFromSuperview()
                        if let schoolName = schoolInfoDict["school_name"] {self.schoolLabel.text = schoolName}
                        if let testTakers = schoolInfoDict["num_of_sat_test_takers"]{self.testTakerLabel.text = "Test Takers: " + testTakers}
                        if let reading = schoolInfoDict["sat_critical_reading_avg_score"]{self.readingLabel.text = "Avg Reading: " + reading}
                        if let math = schoolInfoDict["sat_math_avg_score"]{self.mathLabel.text = "Avg Math: " + math}
                        if let writing = schoolInfoDict["sat_writing_avg_score"]{self.writingLabel.text = "Avg Writing: " + writing}
                        self.schoolLabel.isHidden = false
                        self.testTakerLabel.isHidden = false
                        self.readingLabel.isHidden = false
                        self.mathLabel.isHidden = false
                        self.writingLabel.isHidden = false
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
