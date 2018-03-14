//
//  MainTableViewController.swift
//  20180314-CS-NYCSchools
//
//  Created by Conor Sweeney on 3/14/18.
//  Copyright © 2018 Conor Sweeney. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    var spinner: UIActivityIndicatorView!
    var schools: Array<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        downloadSchoolData()
    }
    
    func setUpView()  {
        //add spinner
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.frame = CGRect(x: self.view.center.x, y:self.view.center.y, width: 20.0, height: 20.0)
        spinner.startAnimating()
        self.view.addSubview(spinner)
    }
    
    func downloadSchoolData() {
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: "https://data.cityofnewyork.us/resource/97mf-9njv.json?$select=school_name")
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
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
                if let schoolArr = json as? [Dictionary<String,String>] {
                    //store the names in a dictionary to check if they have already been added to the list of schools
                    //this prevents duplicates
                    //check runs in O(k)
                    var nameCheckDict = [String:String]()
                    for schoolDict in schoolArr{
                        guard let schoolName = schoolDict["school_name"] else{
                            continue
                        }
                        //edge case for an empty string
                        if schoolName.characters.count > 0 && nameCheckDict[schoolName] == nil{
                            nameCheckDict[schoolName] = "ALREADY ADDED!!!!!!"
                            self.schools.append(schoolName)
                        }
                    }
                }
                //dispatch to main thread to remove spinner and update the header
                DispatchQueue.main.async {
                    self.spinner.removeFromSuperview()
                    self.tableView.reloadData()
                }
            }
            task.resume()
        }
    }
        
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.schools.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = schools[indexPath.row]
        //Please see https://github.com/csweeney285/NBCNewsApp to see how I use lazy image loading to add images to the cells
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //there are enough nil checks for the schools array that its unnecessary to add a guard statement
        presentPopoverSatVC(schoolName: schools[indexPath.row])
    }
    
    //I decided just to implement a simple popover vc to display the SAT data
    func presentPopoverSatVC(schoolName: String){
        //create and pop a simple presentation vc to display the url
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SATViewController") as! SATViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        present(controller, animated: true, completion:  { () -> Void in
            controller.loadSATData(schoolName:schoolName)
        })
        //this is to prevent crash for ipads
        let popoverPresentationController = controller.popoverPresentationController
        popoverPresentationController?.sourceView = self.view
    }
}
