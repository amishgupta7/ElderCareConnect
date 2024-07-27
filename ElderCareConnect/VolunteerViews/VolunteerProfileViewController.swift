//
//  VolunteerProfileViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 9/1/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class VolunteerProfileViewController: UIViewController {

    var volunteerNameLabel = UILabel()
    var volunteerNameTextField = UITextField()
    
    var volunteerAgeLabel = UILabel()
    var volunteerAgeTextField = UITextField()
    
    var volunteerAddressLabel = UILabel()
    var volunteerAddressTextField = UITextField()
    
    var volunteerCityLabel = UILabel()
    var volunteerCityTextField = UITextField()
    
    var volunteerZipcodeLabel = UILabel()
    var volunteerZipcodeTextField = UITextField()
    
    var editButton = UIButton()
    var saveButton = UIButton()
    var cancelButton = UIButton()
    
    var stackView = UIStackView()
    
    var isEditingProfile = false
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setEditingMode(false)
        loadVolunteerProfile()
    }

    func setupUI() {
        view.backgroundColor = .white
        
        stackView = UIStackView(arrangedSubviews: [
            createLabelAndTextFieldStack(label: volunteerNameLabel, textField: volunteerNameTextField, labelText: "Volunteer Name"),
            createLabelAndTextFieldStack(label: volunteerAgeLabel, textField: volunteerAgeTextField, labelText: "Age"),
            createLabelAndTextFieldStack(label: volunteerAddressLabel, textField: volunteerAddressTextField, labelText: "Address"),
            createLabelAndTextFieldStack(label: volunteerCityLabel, textField: volunteerCityTextField, labelText: "City"),
            createLabelAndTextFieldStack(label: volunteerZipcodeLabel, textField: volunteerZipcodeTextField, labelText: "Zipcode")
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.layer.cornerRadius = 15
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor(hex: "#FCD490").cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        view.addSubview(containerView)

        // Create and add buttons
        editButton = createButton(title: "Edit", action: #selector(editButtonClicked))
        saveButton = createButton(title: "Save", action: #selector(saveButtonClicked))
        cancelButton = createButton(title: "Cancel", action: #selector(cancelButtonClicked)) // Cancel button created

        view.addSubview(editButton)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        
        setAllLabelsColor(in: view, color: UIColor(hex: "#340000"))

        // Add constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25),
            
            // Button Constraints
            editButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 15),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 40),
            editButton.widthAnchor.constraint(equalToConstant: 120),
            
            saveButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 15),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.widthAnchor.constraint(equalToConstant: 120),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 15), 
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func createLabelAndTextFieldStack(label: UILabel, textField: UITextField, labelText: String) -> UIStackView {
        label.attributedText = createBoldLabelText(boldText: "\(labelText): ", normalText: "")
        label.isHidden = false
        
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [label, textField])
        stack.axis = .vertical
        stack.spacing = 5
        
        return stack
    }
    
    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Set button appearance
        button.backgroundColor = UIColor(hex: "#F29E12")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return button
    }

    // Load volunteer profile from Firestore
    func loadVolunteerProfile() {
        guard let currentVolunteer = Auth.auth().currentUser else { return }
        db.collection("volunteersprofile").document(currentVolunteer.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                // Set the labels with bold descriptions
                self.volunteerNameLabel.attributedText = self.createBoldLabelText(boldText: "Volunteer Name: ", normalText: data?["name"] as? String ?? "No Name")
                self.volunteerAgeLabel.attributedText = self.createBoldLabelText(boldText: "Age: ", normalText: data?["age"] as? String ?? "No Age")
                self.volunteerAddressLabel.attributedText = self.createBoldLabelText(boldText: "Address: ", normalText: data?["address"] as? String ?? "No Address")
                self.volunteerCityLabel.attributedText = self.createBoldLabelText(boldText: "City: ", normalText: data?["city"] as? String ?? "No City")
                self.volunteerZipcodeLabel.attributedText = self.createBoldLabelText(boldText: "Zipcode: ", normalText: data?["zipcode"] as? String ?? "No Zipcode")
                
                // Update the text fields with plain text from the Firestore document
                self.volunteerNameTextField.text = data?["name"] as? String ?? ""
                self.volunteerAgeTextField.text = data?["age"] as? String ?? ""
                self.volunteerAddressTextField.text = data?["address"] as? String ?? ""
                self.volunteerCityTextField.text = data?["city"] as? String ?? ""
                self.volunteerZipcodeTextField.text = data?["zipcode"] as? String ?? ""
            }
        }
    }

    // Set editing mode
    func setEditingMode(_ isEditing: Bool) {
        isEditingProfile = isEditing

        // Show/hide labels and text fields
        volunteerNameLabel.isHidden = isEditing
        volunteerNameTextField.isHidden = !isEditing
        volunteerAgeLabel.isHidden = isEditing
        volunteerAgeTextField.isHidden = !isEditing
        volunteerAddressLabel.isHidden = isEditing
        volunteerAddressTextField.isHidden = !isEditing
        volunteerCityLabel.isHidden = isEditing
        volunteerCityTextField.isHidden = !isEditing
        volunteerZipcodeLabel.isHidden = isEditing
        volunteerZipcodeTextField.isHidden = !isEditing

        editButton.isHidden = isEditing
        saveButton.isHidden = !isEditing
        cancelButton.isHidden = !isEditing 
    }

    @objc func editButtonClicked() {
        setEditingMode(true)
    }
    
    @objc func cancelButtonClicked() {
        setEditingMode(false)
    }

    // Handle save button click
    @objc func saveButtonClicked() {
        guard let currentVolunteer = Auth.auth().currentUser else { return }
        
        // Prepare the updated data
        let updatedData: [String: Any] = [
            "name": volunteerNameTextField.text ?? "",
            "age": volunteerAgeTextField.text ?? "",
            "address": volunteerAddressTextField.text ?? "",
            "city": volunteerCityTextField.text ?? "",
            "zipcode": volunteerZipcodeTextField.text ?? ""
        ]
        
        let volunteerDocument = db.collection("volunteersprofile").document(currentVolunteer.uid)
        
        volunteerDocument.updateData(updatedData) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                // Update labels with new data, using bold descriptions
                self.volunteerNameLabel.attributedText = self.createBoldLabelText(
                    boldText: "Volunteer Name: ",
                    normalText: self.volunteerNameTextField.text ?? ""
                )

                self.volunteerAgeLabel.attributedText = self.createBoldLabelText(
                    boldText: "Age: ",
                    normalText: self.volunteerAgeTextField.text ?? ""
                )

                self.volunteerAddressLabel.attributedText = self.createBoldLabelText(
                    boldText: "Address: ",
                    normalText: self.volunteerAddressTextField.text ?? ""
                )

                self.volunteerCityLabel.attributedText = self.createBoldLabelText(
                    boldText: "City: ",
                    normalText: self.volunteerCityTextField.text ?? ""
                )

                self.volunteerZipcodeLabel.attributedText = self.createBoldLabelText(
                    boldText: "Zipcode: ",
                    normalText: self.volunteerZipcodeTextField.text ?? ""
                )

                
                // Switch back to static labels
                self.setEditingMode(false)
            }
        }
    }

    // Helper function to create bold labels
    func createBoldLabelText(boldText: String, normalText: String) -> NSAttributedString {
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14)]
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        let boldString = NSMutableAttributedString(string: boldText, attributes: boldAttributes)
        let normalString = NSAttributedString(string: normalText, attributes: normalAttributes)
        boldString.append(normalString)
        return boldString
    }

    func setAllLabelsColor(in view: UIView, color: UIColor) {
        view.subviews.forEach { subview in
            if let label = subview as? UILabel {
                label.textColor = color
            } else {
                setAllLabelsColor(in: subview, color: color) 
            }
        }
    }
}
