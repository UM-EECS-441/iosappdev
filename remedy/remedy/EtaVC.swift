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
        
        bottom_driver_first_name.text = "Driver: \(driver_first_name)"
        bottom_driver_distance.text = "Distance: \(driver_distance)"
        bottom_driver_eta.text = "ETA: \(eta)"
        
    }
    
}
