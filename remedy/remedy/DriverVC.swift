import Foundation
import UIKit
import Cosmos

class DriverVC: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var driverBox: UITextView!
    @IBOutlet var cosmosView: CosmosView!
    var loaded = false
    
    var username = ""
    var driver_username = ""
    var pharmacy_name = ""
    var pharmacy_address = ""
    var pharmacy_lat = 0.0
    var pharmacy_lon = 0.0
    var driver_first_name = ""
    var driver_last_name = ""
    var driver_profile_pic = ""
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
        
        cosmosView.isHidden = true
        spinner.startAnimating()
        loaded = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(loaded)
        sleep(1)
        
        //profile PIC
        
        let driver_profile_pic_url = URL(string: driver_profile_pic)!

        let session = URLSession(configuration: .default)

        let downloadPicTask = session.dataTask(with: driver_profile_pic_url) { (data, response, error) in
            if let e = error {
                print("Error downloading profile picture: \(e)")
            } else {
                if let res = response as? HTTPURLResponse {
                    print("Downloaded profile picture with response code \(res.statusCode)")
                    if let imageData = data {
                        let driverProfilePic = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            let imageView = UIImageView(image: driverProfilePic!)
                            imageView.frame = CGRect(x: 112, y: 315, width: 150, height: 150)
                            self.view.addSubview(imageView)
                        }
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }

        downloadPicTask.resume()
        
        // Star Rating
        cosmosView.isHidden = false
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        cosmosView.backgroundColor = nil
        cosmosView.rating = Double(driver_rating) ?? 0
        cosmosView.settings.filledColor = UIColor.black
        cosmosView.settings.emptyBorderColor = UIColor.black
        cosmosView.settings.filledBorderColor = UIColor.black
        
        spinner.stopAnimating()
        driverBox.font = UIFont(name: "ArialRoundedMTBold", size: 28)
        driverBox.text = "Driver Found!\n\n\n\n\n\n\n\(driver_first_name) \(driver_last_name)\n\n\(driver_car)\n"
        print("driver first name:", driver_first_name)
        
        let btn = UIButton(type: .custom) as UIButton
        btn.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        btn.setTitle("OK", for: .normal)
        btn.titleLabel?.textAlignment = NSTextAlignment.center
        btn.titleLabel?.lineBreakMode = .byWordWrapping
        btn.frame = CGRect(x: 152, y: 645, width: 70, height: 40)
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
            vc?.driver_profile_pic = driver_profile_pic
            vc?.driver_car = driver_car
            vc?.driver_rating = driver_rating
            vc?.driver_lat = driver_lat
            vc?.driver_lon = driver_lon
            vc?.driver_duration = driver_duration
            vc?.driver_distance = driver_distance
            vc?.user_lat = user_lat
            vc?.user_lon = user_lon
            vc?.eta = eta
            vc?.driver_username = driver_username
            vc?.username = username
        }
    }
    
    
    
}
