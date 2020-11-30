import Foundation
import GooglePlaces
import UIKit
import MapKit


class EtaVC: UIViewController {
    
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
    
    var live_eta_timer: Timer?
    
    @IBOutlet var map_screen: MKMapView!
    
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
        print(driver_profile_pic)
        print(driver_car)
        print(driver_rating)
        print(driver_lat)
        print(driver_lon)
        print("duration", driver_duration)
        print("distance", driver_distance)
        print(user_lat)
        print(user_lon)
        print("eta", eta)
        
        let userLocation = CLLocation(latitude: user_lat, longitude: user_lon)
        let pharmacyLocation = CLLocationCoordinate2D(latitude: pharmacy_lat, longitude: pharmacy_lon)
        // var driverLocation = CLLocation(latitude: driver_lat, longitude: driver_lon)
        
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
                            imageView.frame = CGRect(x: 85, y: 57, width: 40, height: 40)
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
        
        let pharm_pin = pin(title: pharmacy_name, locationName: pharmacy_address, coordinate: pharmacyLocation)
        map_screen.addAnnotation(pharm_pin)
        
        map_screen.centerToLocation(userLocation)
        
        live_eta_timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(generate_live_eta), userInfo: nil, repeats: true)
    }
    
    @objc func generate_live_eta() {
        print("live eta generate")
        
        var request = URLRequest(url: URL(string: "https://198.199.90.68/getliveeta/\(username)/\(driver_username)")!)
        request.httpMethod = "GET"
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
                self.driver_distance = json["distance"] as? String ?? ""
                self.eta = json["ETA"] as? String ?? ""
                DispatchQueue.main.async {
                    print("Generated results from request")
                    self.bottom_driver_distance.text = "Distance: \(self.driver_distance)"
                    self.bottom_driver_eta.text = "ETA: \(self.eta)"
                    print(self.driver_distance)
                    print(self.eta)
                    print("Changed on UI")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
        
    }
    
    @IBAction func done_Clicked(_ sender: Any) {
        live_eta_timer?.invalidate()
    }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 8000
  ) {
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

class pin: NSObject, MKAnnotation {
  let title: String?
  let locationName: String?
  let coordinate: CLLocationCoordinate2D

  init(title: String?, locationName: String?, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.locationName = locationName
    self.coordinate = coordinate

    super.init()
  }

  var subtitle: String? {
    return locationName
  }
}
