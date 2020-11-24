import Foundation
import UIKit

class DriverVC: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var driverBox: UITextView!
    var loaded = false
    
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
        sleep(4)
        spinner.stopAnimating()
        driverBox.text = "Boom"
    }
    
    
    
}
