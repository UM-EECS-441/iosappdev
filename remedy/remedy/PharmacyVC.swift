//
//  PharmacyVC.swift
//  remedy
//
//  Created by Anagha Raichur on 10/25/20.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class GeoData {
    var lat: Double
    var lon: Double
    var loc: String
    var facing: String
    var speed: String

    init(lat: Double, lon: Double, loc: String, facing: String, speed: String) {
        self.lat = lat
        self.lon = lon
        self.loc = loc
        self.facing = facing
        self.speed = speed
    }
}

class PharmacyVC: UIViewController, CLLocationManagerDelegate {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    let locmanager = CLLocationManager()
    var geodata = GeoData(lat: 0.0, lon: 0.0, loc: "", facing: "", speed: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

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
        locmanager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Get user's location
            geodata.lat = location.coordinate.latitude
            geodata.lon = location.coordinate.longitude
            print(geodata.lat)
            print(geodata.lon)
            // Reverse geocode to get user's city name
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(location.coordinate) { response , error in
                if let address = response?.firstResult() {
                    let lines = address.lines! as [String]
                    if (lines.count > 0) {
                        // get city name from the first address returned
                        self.geodata.loc = lines[0].components(separatedBy: ", ")[1]
                    }
                }
            }

            // Get user's speed of movement
            if (location.speed < 0.0) {
                // bad reading: probably due to initial fix, try again
                return
            }
            geodata.speed = convertSpeed(location.speed)
            locmanager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if (newHeading.headingAccuracy < 0) {
            // unreliable reading, try again
            return
        }
        locmanager.stopUpdatingHeading()
        geodata.facing = convertHeading(newHeading.magneticHeading)
    }
    func convertHeading(_ heading: Double) -> String {
        let compass = ["North", "NE", "East", "SE", "South", "SW", "West", "NW", "North"]
        let index = Int(round(heading.truncatingRemainder(dividingBy: 360) / 45))
        return compass[index]
    }
    func convertSpeed(_ speed: Double) -> String {
        switch speed {
            case 1.2..<5:
                return "walking"
            case 5..<7:
                return "running"
            case 7..<13:
                return "cycling"
            case 13..<30:
                return "driving"
            case 30..<56:
                return "in train"
            case 56..<256:
                return "flying"
            default:
                return "resting"
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
