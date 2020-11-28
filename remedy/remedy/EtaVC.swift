import Foundation
import GooglePlaces
import UIKit


class EtaVC: UIViewController {
    
    var pharmacy_name = ""
    var pharmacy_address = ""
    var pharmacy_lat = 0.0
    var pharmacy_lon = 0.0
    var driver_first_name = ""
    var driver_last_name = ""
    var driver_car = ""
    var driver_rating = ""
    var driver_lat = 0.0
    var driver_lon = 0.0
    var driver_duration = ""
    var driver_distance = ""
    var user_lat = 0.0
    var user_lon = 0.0
    var eta = ""
    
    @IBOutlet weak var bottom_driver_first_name: UITextView!
    
    @IBOutlet weak var bottom_driver_distance: UITextView!
    
    @IBOutlet weak var bottom_driver_eta: UITextView!
    
    @IBOutlet weak var topBar: UITextView!
    
    @IBOutlet weak var carField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("stuff")
        print(pharmacy_name)
        print(pharmacy_address)
        print(pharmacy_lat)
        print(pharmacy_lon)
        print(driver_first_name)
        print(driver_last_name)
        print(driver_car)
        print(driver_rating)
        print(driver_lat)
        print(driver_lon)
        print("duration", driver_duration)
        print("distance", driver_distance)
        print(user_lat)
        print(user_lon)
        print("eta", eta)
        
        topBar.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.9)
        topBar.layer.cornerRadius = 30
        topBar.textColor = UIColor.white
        topBar.text = "Ongoing Order:\n\(pharmacy_name)"
        topBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        topBar.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        topBar.layer.shadowOpacity = 0.5
        topBar.layer.shadowRadius = 0.4
        topBar.layer.masksToBounds = false
        
        bottom_driver_first_name.text = "Driver: \(driver_first_name)"
        bottom_driver_distance.text = "Distance: \(driver_distance)"
        bottom_driver_eta.text = "ETA: \(eta)"
        
        carField.text = driver_car
        
    }
    
}
