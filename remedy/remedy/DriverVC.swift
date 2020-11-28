import Foundation
import UIKit

class DriverVC: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var driverBox: UITextView!
    var loaded = false
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        driverBox.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        driverBox.layer.cornerRadius = 30
        driverBox.textColor = UIColor.white
        driverBox.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        driverBox.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        driverBox.layer.shadowOpacity = 1.0
        driverBox.layer.shadowRadius = 0.4
        driverBox.layer.masksToBounds = false
        
        spinner.startAnimating()
        loaded = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(loaded)
        sleep(1)
        spinner.stopAnimating()
        driverBox.text = "Driver Found!\n\n\(driver_first_name) \(driver_last_name)\n\(driver_rating)\n\n\(driver_car)\n"
        print("driver first name:", driver_first_name)
        
        let btn = UIButton(type: .custom) as UIButton
        btn.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        btn.setTitle("OK", for: .normal)
        btn.titleLabel?.textAlignment = NSTextAlignment.center
        btn.titleLabel?.lineBreakMode = .byWordWrapping
        btn.frame = CGRect(x: 152, y: 590, width: 70, height: 40)
        btn.layer.cornerRadius = 15
        btn.addTarget(self, action: #selector(self.okClicked), for: .touchUpInside)
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 0.4
        btn.layer.masksToBounds = false
        self.view.addSubview(btn)
    }
    
    @objc func okClicked() {
        print("ok clicked")
        performSegue(withIdentifier: "toEtaVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is EtaVC {
            let vc = segue.destination as? EtaVC
            vc?.pharmacy_name = pharmacy_name
            vc?.pharmacy_address = pharmacy_address
            vc?.pharmacy_lat = pharmacy_lat
            vc?.pharmacy_lon = pharmacy_lon
            vc?.driver_first_name = driver_first_name
            vc?.driver_last_name = driver_last_name
            vc?.driver_car = driver_car
            vc?.driver_rating = driver_rating
            vc?.driver_lat = driver_lat
            vc?.driver_lon = driver_lon
            vc?.driver_duration = driver_duration
            vc?.driver_distance = driver_distance
            vc?.user_lat = user_lat
            vc?.user_lon = user_lon
            vc?.eta = eta
        }
    }
    
    
    
}
