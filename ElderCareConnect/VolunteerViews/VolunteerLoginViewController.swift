//
//  VolunteerLoginViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 6/20/24.
//

import UIKit
import Firebase
import FirebaseAuth

class VolunteerLoginViewController: UIViewController {

//    var isLoggedOut: Bool = false
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var WarningLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = Global.navcustomColor
        self.WarningLabel.text = ""

    }
    
    @IBAction func LoginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let e = error {
                self.WarningLabel.text = e.localizedDescription
            }
            else
            {
                self.performSegue(withIdentifier: "goToVolunteer", sender: self)
            }
        }
    }
    
    @IBAction func CreateAccountClicked(_ sender: UIButton) {
        self.WarningLabel.text = ""
    }
}
