//
//  AdminLoginViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 6/14/24.
//

import UIKit
import Firebase
import FirebaseAuth

class AdminLoginViewController: UIViewController {

    @IBOutlet weak var adminEmailTextField: UITextField!
    @IBOutlet weak var adminPasswordTextField: UITextField!
    @IBOutlet weak var adminLoginWarningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = Global.navcustomColor
        self.adminLoginWarningLabel.text = ""
    }
    
    @IBAction func LoginClicked(_ sender: UIButton) {
        guard let email = adminEmailTextField.text else { return }
        guard let password = adminPasswordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let e = error {
                self.adminLoginWarningLabel.text = e.localizedDescription
            }
            else
            {
                self.performSegue(withIdentifier: "goToAdmin", sender: self)
            }
        }
    }
    
    @IBAction func CreateAccountClicked(_ sender: UIButton) {
        self.adminLoginWarningLabel.text = ""
    }

}
