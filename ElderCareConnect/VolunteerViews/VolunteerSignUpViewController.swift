//
//  VolunteerSignUpViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 7/15/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class VolunteerSignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var WarningLabel: UILabel!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var volunteerFieldsStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a container view for the stack view and other elements
        let containerView = UIView()
        self.navigationItem.hidesBackButton = true
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor(hex: "#FCD490").cgColor
        containerView.layer.backgroundColor = UIColor.systemBackground.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
     
        view.addSubview(containerView)
        self.WarningLabel.text = ""
        // Add stackView to the containerView
        containerView.addSubview(volunteerFieldsStackView)

        // Set constraints for the containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])

        // Set constraints for the stackView inside the containerView
        volunteerFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            volunteerFieldsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            volunteerFieldsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            volunteerFieldsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            volunteerFieldsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25)
        ])

        view.addSubview(buttonStackView)
     

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100)
        ])
    }
    
    @IBAction func signupClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text else {return}
        guard let age = ageTextField.text else {return}
        guard let address = addressTextField.text else {return}
        guard let city = cityTextField.text else {return}
        guard let zipcode = zipcodeTextField.text else {return}
        
        
        Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            if let e = error {
                self.WarningLabel.textColor = UIColor.red
                self.WarningLabel.text = e.localizedDescription
            }
            else 
            {
                guard let user = firebaseResult?.user else { return }
                let db = Firestore.firestore()
                db.collection("volunteersprofile").document(user.uid).setData([
                    "name": name,
                    "age": age,
                    "email": email,
                    "address": address,
                    "city": city,
                    "zipcode": zipcode,
                ]) {error in
                    if let error = error {
                        self.WarningLabel.text = "Error saving user profile: \(error.localizedDescription)"
                    } else {
                        // Success: Show pop-up message and navigate to login page
                        let alertController = UIAlertController(title: "Welcome Aboard!",
                                                                message: "Your profile is created successfully! Want to navigate to the login page?",
                                                                preferredStyle: .alert)
                        
                        let navigateAction = UIAlertAction(title: "Yes", style: .default) { _ in
                            if let volunteerLoginVC = self.navigationController?.viewControllers.first(where: { $0 is VolunteerLoginViewController }) {
                                self.navigationController?.popToViewController(volunteerLoginVC, animated: true)
                            }
                                                }
                        
                        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

                        alertController.addAction(navigateAction)
                        alertController.addAction(cancelAction)

                        self.present(alertController, animated: true, completion: nil)
                        
                        // Clear fields after successful signup
                        self.clearAllFields()
                    }
                }
                
              
            }
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Clear All Fields", message: "Are you sure you want to clear all the fields?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                self.clearAllFields()
            }
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    
    // Function to clear all the text fields
        func clearAllFields() {
            emailTextField.text = ""
            passwordTextField.text = ""
            nameTextField.text = ""
            ageTextField.text = ""
            addressTextField.text = ""
            cityTextField.text = ""
            zipcodeTextField.text = ""
            WarningLabel.text = ""
        }
}
