import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON

class pharmacy {
    var name: String
    var address: String
    var lat: Double
    var lon: Double
    
    init(name: String, address: String, lat: Double, lon: Double) {
        self.name = name
        self.address = address
        self.lat = lat
        self.lon = lon
    }
}

class GeoData_1 {
    var lat: Double
    var lon: Double

    init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
}

class PharmacyVC: UIViewController, CLLocationManagerDelegate, UISearchControllerDelegate {
    

    @IBOutlet weak var pharmacy_one: UIButton!
    
    @IBOutlet weak var pharmacy_two: UIButton!
    
    @IBOutlet weak var pharmacy_three: UIButton!
    
    @IBOutlet weak var pharmacy_four: UIButton!
    
    @IBOutlet weak var pharmacy_five: UIButton!
    
    @IBOutlet var spinner1: UIActivityIndicatorView!
    
    @IBOutlet var spinner2: UIActivityIndicatorView!
    
    @IBOutlet var spinner3: UIActivityIndicatorView!
    
    @IBOutlet var spinner4: UIActivityIndicatorView!
    
    @IBOutlet var spinner5: UIActivityIndicatorView!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    let locmanager = CLLocationManager()
    var geodata = GeoData_1(lat: 0.0, lon: 0.0)
    
    var pharmacies = [pharmacy]()
    
    var button_tag = 0
    
    var username = ""
    
    var searchExecuted = 0
    var search_pharmacy_name = ""
    var search_pharmacy_address = ""
    var search_pharmacy_lat = 0.0
    var search_pharmacy_lon = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pharmacy_one
        pharmacy_one.tag = 1
        pharmacy_one.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        pharmacy_one.setTitleColor(.white, for: .normal)
        pharmacy_one.titleLabel?.textAlignment = NSTextAlignment.center
        pharmacy_one.titleLabel?.lineBreakMode = .byWordWrapping
        // pharmacy_one.frame = CGRect(x: 28, y: y_val, width: 320, height: 100)
        pharmacy_one.layer.cornerRadius = 20
        pharmacy_one.addTarget(self, action: #selector(self.clickMe), for: .touchUpInside)
        pharmacy_one.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        pharmacy_one.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        pharmacy_one.layer.shadowOpacity = 1.0
        pharmacy_one.layer.shadowRadius = 0.4
        pharmacy_one.layer.masksToBounds = false
        view.addSubview(self.pharmacy_one)
        
        // pharmacy_two
        pharmacy_two.tag = 2
        pharmacy_two.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        pharmacy_two.setTitleColor(.white, for: .normal)
        pharmacy_two.titleLabel?.textAlignment = NSTextAlignment.center
        pharmacy_two.titleLabel?.lineBreakMode = .byWordWrapping
        // pharmacy_two.frame = CGRect(x: 28, y: y_val, width: 320, height: 100)
        pharmacy_two.layer.cornerRadius = 20
        pharmacy_two.addTarget(self, action: #selector(self.clickMe), for: .touchUpInside)
        pharmacy_two.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        pharmacy_two.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        pharmacy_two.layer.shadowOpacity = 1.0
        pharmacy_two.layer.shadowRadius = 0.4
        pharmacy_two.layer.masksToBounds = false
        view.addSubview(self.pharmacy_two)
        
        // pharmacy_three
        pharmacy_three.tag = 3
        pharmacy_three.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        pharmacy_three.setTitleColor(.white, for: .normal)
        pharmacy_three.titleLabel?.textAlignment = NSTextAlignment.center
        pharmacy_three.titleLabel?.lineBreakMode = .byWordWrapping
        // pharmacy_three.frame = CGRect(x: 28, y: y_val, width: 320, height: 100)
        pharmacy_three.layer.cornerRadius = 20
        pharmacy_three.addTarget(self, action: #selector(self.clickMe), for: .touchUpInside)
        pharmacy_three.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        pharmacy_three.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        pharmacy_three.layer.shadowOpacity = 1.0
        pharmacy_three.layer.shadowRadius = 0.4
        pharmacy_three.layer.masksToBounds = false
        view.addSubview(self.pharmacy_three)
        
        // pharmacy_four
        pharmacy_four.tag = 4
        pharmacy_four.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        pharmacy_four.setTitleColor(.white, for: .normal)
        pharmacy_four.titleLabel?.textAlignment = NSTextAlignment.center
        pharmacy_four.titleLabel?.lineBreakMode = .byWordWrapping
        // pharmacy_four.frame = CGRect(x: 28, y: y_val, width: 320, height: 100)
        pharmacy_four.layer.cornerRadius = 20
        pharmacy_four.addTarget(self, action: #selector(self.clickMe), for: .touchUpInside)
        pharmacy_four.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        pharmacy_four.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        pharmacy_four.layer.shadowOpacity = 1.0
        pharmacy_four.layer.shadowRadius = 0.4
        pharmacy_four.layer.masksToBounds = false
        view.addSubview(self.pharmacy_four)
        
        // pharmacy_five
        pharmacy_five.tag = 5
        pharmacy_five.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        pharmacy_five.setTitleColor(.white, for: .normal)
        pharmacy_five.titleLabel?.textAlignment = NSTextAlignment.center
        pharmacy_five.titleLabel?.lineBreakMode = .byWordWrapping
        // pharmacy_five.frame = CGRect(x: 28, y: y_val, width: 320, height: 100)
        pharmacy_five.layer.cornerRadius = 20
        pharmacy_five.addTarget(self, action: #selector(self.clickMe), for: .touchUpInside)
        pharmacy_five.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        pharmacy_five.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        pharmacy_five.layer.shadowOpacity = 1.0
        pharmacy_five.layer.shadowRadius = 0.4
        pharmacy_five.layer.masksToBounds = false
        view.addSubview(self.pharmacy_five)
        
        spinner1.startAnimating()
        spinner2.startAnimating()
        spinner3.startAnimating()
        spinner4.startAnimating()
        spinner5.startAnimating()
        
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.delegate = self
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        resultsViewController?.autocompleteFilter = filter

        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))

        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        
        // Configure the location manager.
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBest
        locmanager.requestWhenInUseAuthorization()

        // and start getting user's current location and heading
        locmanager.startUpdatingLocation()
        
        print("username recieved:", username)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Get user's location
            geodata.lat = location.coordinate.latitude
            geodata.lon = location.coordinate.longitude
            //getPharmList()
            print(geodata.lat, geodata.lon)
            locmanager.stopUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getPharmList()
    }
    
    func getPharmList() {
        print("test")
        print("username recieved:", username)
        print(geodata.lat, geodata.lon)
        let requestURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(geodata.lat),\(geodata.lon)&rankby=distance&type=drugstore&key=AIzaSyBwVdb3vtPPg_RuaVwaKDlWOLN3woENo6Y"

        var request = URLRequest(url: URL(string: requestURL)!)
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
              
                let json = JSON(try JSONSerialization.jsonObject(with: data!) as! [String:Any])
                // loading in pharmacies to UI
                DispatchQueue.main.async {
                    self.pharmacy_one.setTitle("\((json["results"][1]["name"].string)!)\n\n\((json["results"][1]["vicinity"].string)!)", for: .normal)
                    self.spinner1.stopAnimating()
                    
                    self.pharmacy_two.setTitle("\((json["results"][2]["name"].string)!)\n\n\((json["results"][2]["vicinity"].string)!)", for: .normal)
                    self.spinner2.stopAnimating()
                    
                    self.pharmacy_three.setTitle("\((json["results"][3]["name"].string)!)\n\n\((json["results"][3]["vicinity"].string)!)", for: .normal)
                    self.spinner3.stopAnimating()
                    
                    self.pharmacy_four.setTitle("\((json["results"][4]["name"].string)!)\n\n\((json["results"][4]["vicinity"].string)!)", for: .normal)
                    self.spinner4.stopAnimating()
                    
                    self.pharmacy_five.setTitle("\((json["results"][5]["name"].string)!)\n\n\((json["results"][5]["vicinity"].string)!)", for: .normal)
                    self.spinner5.stopAnimating()
                }
                
//                var y_val = 200
//                var i = 0;
                
                for pharm in json["results"] {
                    let name = pharm.1["name"].string
                    let address = pharm.1["vicinity"].string
                    let lat = pharm.1["geometry"]["location"]["lat"].double
                    let lon = pharm.1["geometry"]["location"]["lng"].double
                    let sing_pharm = pharmacy(name: name!, address: address!, lat: lat!, lon: lon!)
                    self.pharmacies.append(sing_pharm)
                    
                }
                
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    @objc func clickMe(sender:UIButton!) {
        searchExecuted = 0
        button_tag = sender.tag
        performSegue(withIdentifier: "toConfirmation", sender: nil)
    }
    
    @objc func searchOptionClicked() {
        searchExecuted = 1
        performSegue(withIdentifier: "toConfirmation", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ConfirmationVC {
            let vc = segue.destination as? ConfirmationVC
            if searchExecuted == 0 {
                vc?.pharmacy_name = pharmacies[button_tag].name
                vc?.pharmacy_address = pharmacies[button_tag].address
                vc?.pharmacy_lat = pharmacies[button_tag].lat
                vc?.pharmacy_lon = pharmacies[button_tag].lon
            }
            else {
                vc?.pharmacy_name = search_pharmacy_name
                vc?.pharmacy_address = search_pharmacy_address
                vc?.pharmacy_lat = search_pharmacy_lat
                vc?.pharmacy_lon = search_pharmacy_lon
            }
            vc?.username = username
            vc?.user_lat = geodata.lat
            vc?.user_lon = geodata.lon
        }
    }
}


// Handle the user's selection.b
extension PharmacyVC: GMSAutocompleteResultsViewControllerDelegate {
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController?.isActive = false
    
    // Do something with the selected place.
    search_pharmacy_name = place.name!
    search_pharmacy_address = place.formattedAddress!
    search_pharmacy_lat = place.coordinate.latitude
    search_pharmacy_lon = place.coordinate.longitude
    print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place attributions: \(place.coordinate)")
  }
    //place.openingHours
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}

extension PharmacyVC {
    func didDismissSearchController(_ searchController: UISearchController) {
        searchOptionClicked()
    }
}
