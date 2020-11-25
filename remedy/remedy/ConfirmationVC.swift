//
//  ConfirmationVC.swift
//  remedy
//
//  Created by Anagha Raichur on 10/25/20.
//

import UIKit


class ConfirmationVC: UIViewController {
    var pharmacy_name = ""
    var pharmacy_address = ""
    var pharmacy_lat = 0.0
    var pharmacy_lon = 0.0
    
    var closestDriver = Driver()
    

    @IBOutlet weak var confirmBoxText: UITextView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        
        confirmBoxText.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        confirmBoxText.layer.cornerRadius = 30
        confirmBoxText.textColor = UIColor.white
        confirmBoxText.text = "\n\(pharmacy_name)\n\n\(pharmacy_address)"
        confirmBoxText.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        confirmBoxText.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        confirmBoxText.layer.shadowOpacity = 1.0
        confirmBoxText.layer.shadowRadius = 0.4
        confirmBoxText.layer.masksToBounds = false
        
        confirmButton.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        confirmButton.layer.shadowOpacity = 0.5
        confirmButton.layer.shadowRadius = 0.4
        confirmButton.layer.masksToBounds = false
        
        print(pharmacy_name, pharmacy_address, pharmacy_lat, pharmacy_lon)
    }
    
    @IBAction func passPharmacy(_ sender: Any) {
        let json: [String: Any] = ["username": "new_guy",
                                "pharmacyLat": pharmacy_lat,
                                "pharmacyLon": pharmacy_lon
                                ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: URL(string: "https://198.199.90.68/getclosestdriver/")!)
        request.httpMethod = "GET"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                self.closestDriver.first_name = json["first_name"] as? String ?? ""
                self.closestDriver.last_name = json["last_name"] as? String ?? ""
                self.closestDriver.car = json["car"] as? String ?? ""
                self.closestDriver.rating = json["rating"] as? String ?? ""
                self.closestDriver.lat = json["lat"] as? Float ?? 0
                self.closestDriver.lon = json["lon"] as? Float ?? 0
                self.closestDriver.duration = json["duration"] as? String ?? ""
                self.closestDriver.distance = json["distance"] as? String ?? ""
                print(self.closestDriver.first_name + " " + self.closestDriver.last_name)
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
        dismiss(animated: true, completion: nil)
    }
}
