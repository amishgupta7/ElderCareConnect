//
//  AdminCreateRequestViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 7/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AdminCreateRequestViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var seniorNameTextField: UITextField!
    @IBOutlet weak var seniorAgeTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var serviceTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var requestDatepicker: UIDatePicker!
    @IBOutlet weak var specialNotesTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var fromTimePicker: UIDatePicker!
    @IBOutlet weak var toTimePicker: UIDatePicker!
    @IBOutlet weak var createRequestFieldsStackView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    
    // Firebase Firestore database reference
    let db = Firestore.firestore()
    
    let serviceOptions = [
            "Service Request for Daily Assistance",
            "Medical Appointment Request",
            "Grocery/Essentials Delivery Request",
            "Companionship Visit Request",
            "Event Participation Request",
            "Emergency Help Request",
            "Meal Delivery Request",
            "Technology Support Request",
            "Transportation Request",
            "Companion for Outdoor Walks",
            "Wellness Check Request",
            "Social Activity Request",
            "Physical Therapy or Exercise Assistance"
        ]
    
    let genderOptions = ["Male", "Female"]

        // Create picker views for service and gender
        let servicePickerView = UIPickerView()
        let genderPickerView = UIPickerView()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // All fields are valid, proceed with the request
            warningLabel.text = ""
             
            let containerView = UIView()
            containerView.layer.cornerRadius = 15
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = UIColor(hex: "#FCD490").cgColor
            containerView.layer.backgroundColor = UIColor.systemBackground.cgColor
            containerView.translatesAutoresizingMaskIntoConstraints = false
         
            view.addSubview(containerView)
            containerView.addSubview(createRequestFieldsStackView)

            // Set constraints for the containerView
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
            ])

            // Set constraints for the stackView inside the containerView
            createRequestFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                createRequestFieldsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
                createRequestFieldsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
                createRequestFieldsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
                createRequestFieldsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25)
            ])

            view.addSubview(buttonStackView)
         

            buttonStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buttonStackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
                buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
                buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70)
            ])
            
            // Setting up the picker for serviceTextField
            servicePickerView.delegate = self
            servicePickerView.dataSource = self
            serviceTextField.inputView = servicePickerView
            
            // Setting up the picker for genderTextField
            genderPickerView.delegate = self
            genderPickerView.dataSource = self
            genderTextField.inputView = genderPickerView
            
            // Add toolbar with 'Done' button for both text fields
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
            toolbar.setItems([doneButton], animated: false)
            
            serviceTextField.inputAccessoryView = toolbar
            genderTextField.inputAccessoryView = toolbar
            
            fromTimePicker.contentHorizontalAlignment = .left
            toTimePicker.contentHorizontalAlignment = .left
            requestDatepicker.contentHorizontalAlignment = .left
        }
        
        // MARK: - UIPickerView DataSource
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView == servicePickerView {
                return serviceOptions.count
            } else if pickerView == genderPickerView {
                return genderOptions.count
            }
            return 0
        }
        
        // MARK: - UIPickerView Delegate
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerView == servicePickerView {
                return serviceOptions[row]
            } else if pickerView == genderPickerView {
                return genderOptions[row]
            }
            return nil
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if pickerView == servicePickerView {
                serviceTextField.text = serviceOptions[row]
            } else if pickerView == genderPickerView {
                genderTextField.text = genderOptions[row]
            }
        }
        
        // MARK: - Toolbar Done Button Action
        @objc func doneTapped() {
            serviceTextField.resignFirstResponder()
            genderTextField.resignFirstResponder()
        }
        
        @IBAction func createRequestTapped(_ sender: UIButton) {
            guard let seniorName = seniorNameTextField.text, !seniorName.isEmpty,
                  let seniorAgeString = seniorAgeTextField.text, let seniorAge = Int(seniorAgeString),
                  let serviceType = serviceTextField.text, !serviceType.isEmpty,
                  let gender = genderTextField.text, !gender.isEmpty,
                  let description = descriptionTextField.text, !description.isEmpty else {
                self.warningLabel.textColor = UIColor.red
                self.warningLabel.text = "Please fill out all required fields. Special Notes are optional!"
                return
            }
            
            let specialNotes = specialNotesTextField.text ?? ""
            
            // Get selected date, from time, and to time from the date and time pickers
            let selectedDate = requestDatepicker.date
            let fromTime = fromTimePicker.date
            let toTime = toTimePicker.date
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let formattedDate = dateFormatter.string(from: selectedDate)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            let formattedFromTime = timeFormatter.string(from: fromTime)
            let formattedToTime = timeFormatter.string(from: toTime)
            
            // Retrieve the current logged-in user's UID (adminId)
            guard let currentUser = Auth.auth().currentUser else {
                self.warningLabel.textColor = UIColor.red
                self.warningLabel.text = "No user is logged in"
                return
            }
            
            let adminId = currentUser.uid
            
            let newRequest: [String: Any] = [
                "elderName": seniorName,
                "elderAge": seniorAge,
                "gender": gender,
                "requestType": serviceType,
                "description": description,
                "requestDate": formattedDate,
                "requestFromTime": formattedFromTime,
                "requestToTime": formattedToTime,
                "specialnotes": specialNotes,
                "status": "Pending",
                "adminId": adminId,
                "volunteerId": NSNull(),
                "createdAt": Timestamp(),
                "updatedAt": Timestamp()
            ]
            
            // Add the request to Firestore
            db.collection("requests").addDocument(data: newRequest) { error in
                if let error = error {
                    self.warningLabel.textColor = UIColor.red
                    self.warningLabel.text = "Error adding document: \(error)"
                } else {
                    // Request created successfully, show the message box
                    self.showCompletionAlert()
                    self.clearAllFields()
                }
            }
        }

        // Function to show a message box asking if the user wants to create another request or go to the dashboard
        func showCompletionAlert() {
            let alert = UIAlertController(title: "Request Completed", message: "Request is successfully created! Would you like to create another request or return to the dashboard?", preferredStyle: .alert)
            
            let createMoreAction = UIAlertAction(title: "Create More", style: .default) { _ in
                self.clearAllFields()
            }
            
            // "Go to Dashboard" action
            let goToDashboardAction = UIAlertAction(title: "Go to Dashboard", style: .default) { _ in
                if let tabBarController = self.tabBarController {
                    // Assuming AdminDashboardViewController is in a specific tab, e.g., index 0
                    tabBarController.selectedIndex = 0
                    if let navController = tabBarController.viewControllers?[0] as? UINavigationController {
                        navController.popToRootViewController(animated: true)
                    }
                }
            }
            
            alert.addAction(createMoreAction)
            alert.addAction(goToDashboardAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    
    @IBAction func clearButton(_ sender: Any) {
        clearAllFields()
    }
    
        // Function to clear all fields and reset controls
        func clearAllFields() {
            seniorNameTextField.text = ""
            seniorAgeTextField.text = ""
            serviceTextField.text = ""
            genderTextField.text = ""
            descriptionTextField.text = ""
            specialNotesTextField.text = ""
            warningLabel.text = ""
            requestDatepicker.setDate(Date(), animated: true)
            fromTimePicker.setDate(Date(), animated: true)
            toTimePicker.setDate(Date(), animated: true)
           
        }
    }
