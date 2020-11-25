//
//  Driver.swift
//  remedy
//
//  Created by Anagha Raichur on 11/25/20.
//

import Foundation
import UIKit

class Driver {
    var first_name: String
    var last_name: String
    var car: String
    var rating: String
    var lat: Float
    var lon: Float
    var duration: String
    var distance: String
    
    init(){
        self.first_name = ""
        self.last_name = ""
        self.car = ""
        self.rating = ""
        self.lat = 0
        self.lon = 0
        self.duration = ""
        self.distance = ""
    }
    
    init(first_name: String, last_name: String, car: String, rating: String, lat: Float, lon: Float, duration: String, distance: String) {
        self.first_name = first_name
        self.last_name = last_name
        self.car = car
        self.rating = rating
        self.lat = lat
        self.lon = lon
        self.duration = duration
        self.distance = distance
    }
}