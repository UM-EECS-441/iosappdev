//
//  UsernameVC.swift
//  remedy
//
//  Created by Anagha Raichur on 11/24/20.
//

import Foundation
import UIKit

class UsernameVC: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var enterButton: UIButton!
    
    var username = ""
    
    override func viewDidLoad() {
        
        enterButton.backgroundColor = UIColor(red: 227/255, green: 120/255, blue: 120/255, alpha: 0.7)
        enterButton.layer.cornerRadius = 10
        enterButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        enterButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        enterButton.layer.shadowOpacity = 0.5
        enterButton.layer.shadowRadius = 0.4
        enterButton.layer.masksToBounds = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PharmacyVC {
            let vc = segue.destination as? PharmacyVC
            vc?.username = usernameField.text!
            print("username:", vc?.username)
        }
    }
    
    
    
}
