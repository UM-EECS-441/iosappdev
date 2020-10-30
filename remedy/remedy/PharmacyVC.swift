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
    var open: Bool
    
    init(name: String, address: String, lat: Double, lon: Double, open: Bool) {
        self.name = name
        self.address = address
        self.lat = lat
        self.lon = lon
        self.open = open
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

class PharmacyVC: UIViewController, CLLocationManagerDelegate {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    let locmanager = CLLocationManager()
    var geodata = GeoData_1(lat: 0.0, lon: 0.0)
    
    var pharmacies = [pharmacy]()
    
    var button_tag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Get user's location
            geodata.lat = location.coordinate.latitude
            geodata.lon = location.coordinate.longitude
            print(geodata.lat)
            print(geodata.lon)
            getPharmList()
            locmanager.stopUpdatingLocation()
        }
    }
    
    func getPharmList() {
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
//                print(json)
                
                var y_val = 200
                var i = 0;
                for pharm in json["results"] {
                    let name = pharm.1["name"].string
                    let address = pharm.1["vicinity"].string
                    let lat = pharm.1["geometry"]["location"]["lat"].double
                    let lon = pharm.1["geometry"]["location"]["lng"].double
                    let open = pharm.1["opening_hours"]["open_now"].bool
                    let sing_pharm = pharmacy(name: name!, address: address!, lat: lat!, lon: lon!, open: open!)
                    self.pharmacies.append(sing_pharm)
                    
                    
                    let btn = UIButton(type: .custom) as UIButton
                    btn.tag = i
                    btn.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
                    btn.setTitle("\(name!)\n\(address!)", for: .normal)
                    btn.titleLabel?.textAlignment = NSTextAlignment.center
                    btn.titleLabel?.lineBreakMode = .byWordWrapping
                    btn.frame = CGRect(x: 28, y: y_val, width: 320, height: 100)
                    btn.layer.cornerRadius = 30
                    btn.addTarget(self, action: #selector(self.clickMe), for: .touchUpInside)
                    btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
                    btn.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
                    btn.layer.shadowOpacity = 1.0
                    btn.layer.shadowRadius = 0.4
                    btn.layer.masksToBounds = false
                    self.view.addSubview(btn)
                    

                    y_val = y_val + 120
                    i = i + 1
                    if i == 5 {
                        break
                    }
                    
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    @objc func clickMe(sender:UIButton!) {
        print("Button Clicked")
        print(sender.tag)
        print(self.pharmacies[sender.tag].address)
        print("done")
        button_tag = sender.tag
        
        performSegue(withIdentifier: "toConfirmation", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ConfirmationVC {
            let vc = segue.destination as? ConfirmationVC
            vc?.pharmacy_name = pharmacies[button_tag].name
            vc?.pharmacy_address = pharmacies[button_tag].address
            vc?.pharmacy_lat = pharmacies[button_tag].lat
            vc?.pharmacy_lon = pharmacies[button_tag].lon
            vc?.pharmacy_open = pharmacies[button_tag].open
        }
    }
    
   
}


// Handle the user's selection.b
extension PharmacyVC: GMSAutocompleteResultsViewControllerDelegate {
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController?.isActive = false
    
    // Do something with the selected place.
    print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place attributions: \(place.attributions)")
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
