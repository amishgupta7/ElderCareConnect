//
//  AdminSignUpViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 6/28/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AdminSignUpViewController: UIViewController {
    
    @IBOutlet weak var adminNameTextField: UITextField!
    @IBOutlet weak var adminEmailTextField: UITextField!
    @IBOutlet weak var adminPasswordTextField: UITextField!
    @IBOutlet weak var adminContactNumberTextField: UITextField!
    @IBOutlet weak var oldAgeHomeNameTextField: UITextField!
    @IBOutlet weak var oldAgeHomeAddressTextField: UITextField!
    @IBOutlet weak var adminCityTextField: UITextField!
    @IBOutlet weak var adminZipcodeTextField: UITextField!
    @IBOutlet weak var adminWarningLabel: UILabel!
    @IBOutlet weak var adminStackView: UIStackView!
    @IBOutlet weak var adminSignUpButton: UIButton!
    @IBOutlet weak var adminButtoonStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a container view for the stack view and other elements
        let containerView = UIView()
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor(hex: "#FCD490").cgColor
        containerView.layer.backgroundColor = UIColor.systemBackground.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
     
        view.addSubview(containerView)
        self.adminWarningLabel.text = ""
        // Add stackView to the containerView
        containerView.addSubview(adminStackView)

        // Set constraints for the containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])

        // Set constraints for the stackView inside the containerView
        adminStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adminStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            adminStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            adminStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            adminStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25)
        ])

        view.addSubview(adminButtoonStackView)
     

        adminButtoonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adminButtoonStackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            adminButtoonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            adminButtoonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100)
        ])
    }

    
    @IBAction func adminSignUpClicked(_ sender: Any) {
        
        if adminNameTextField.text?.isEmpty == true ||
                adminEmailTextField.text?.isEmpty == true ||
                adminPasswordTextField.text?.isEmpty == true ||
                adminContactNumberTextField.text?.isEmpty == true ||
                oldAgeHomeNameTextField.text?.isEmpty == true ||
                oldAgeHomeAddressTextField.text?.isEmpty == true ||
                adminCityTextField.text?.isEmpty == true ||
                adminZipcodeTextField.text?.isEmpty == true {
                
                // Show alert if any field is empty
            self.adminWarningLabel.text = "All fields are required. Please fill in all fields."
                return
            }
        
            guard let adminName = adminNameTextField.text else { return }
            guard let password = adminPasswordTextField.text else { return }
            guard let email = adminEmailTextField.text else { return }
            guard let contact = adminContactNumberTextField.text else { return }
            guard let oldAgeHomeName = oldAgeHomeNameTextField.text else { return }
            guard let oldAgeHomeaddress = oldAgeHomeAddressTextField.text else { return }
            guard let city = adminCityTextField.text else { return }
            guard let zipcode = adminZipcodeTextField.text else { return }

            Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
                if let e = error {
                    self.adminWarningLabel.textColor = UIColor.red
                    self.adminWarningLabel.text = e.localizedDescription
                } else {
                    guard let user = firebaseResult?.user else { return }
                    let db = Firestore.firestore()
                    db.collection("adminsprofile").document(user.uid).setData([
                        "admin name": adminName,
                        "email": email,
                        "contactnumber": contact,
                        "oldagehomename": oldAgeHomeName,
                        "oldagehomeaddress": oldAgeHomeaddress,
                        "city": city,
                        "zipcode": zipcode,
                        "createdatetime": Timestamp(date: Date()) 
                    ]) { error in
                        if let error = error {
                            self.adminWarningLabel.text = "Error saving user profile: \(error.localizedDescription)"
                        } else {
                            self.clearAllTextFields()

                            // Show the success message in a pop-up window
                            let alertController = UIAlertController(
                                title: "Welcome aboard!",
                                message: "Your account has been created. Do you want to go back to the login page or stay here?",
                                preferredStyle: .alert
                            )
                            let yesAction = UIAlertAction(title: "Go to Login", style: .default) { _ in
                                // Navigate back to the previous view controller
                                self.navigationController?.popViewController(animated: true)
                            }
                            let noAction = UIAlertAction(title: "Stay Here", style: .cancel, handler: nil)

                            alertController.addAction(yesAction)
                            alertController.addAction(noAction)

                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
    }
    
    
    @IBAction func adminClearClick(_ sender: Any) {
        let alertController = UIAlertController(title: "Clear All Fields", message: "Are you sure you want to clear all the fields?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                self.clearAllTextFields()
            }
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    // Function to clear all text fields
    func clearAllTextFields() {
        self.adminNameTextField.text = ""
        self.adminEmailTextField.text = ""
        self.adminPasswordTextField.text = ""
        self.adminContactNumberTextField.text = ""
        self.oldAgeHomeNameTextField.text = ""
        self.oldAgeHomeAddressTextField.text = ""
        self.adminCityTextField.text = ""
        self.adminZipcodeTextField.text = ""
        self.adminWarningLabel.text = ""
    }
}
