//
//  AdminProfileViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 9/14/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AdminProfileViewController: UIViewController {

    var adminNameLabel = UILabel()
    var adminNameTextField = UITextField()
    
    var adminContactNumberLabel = UILabel()
    var adminContactNumberTextField = UITextField()
    
    var oldAgeHomeNameLabel = UILabel()
    var oldAgeHomeNameTextField = UITextField()
    
    var oldAgeHomeAddressLabel = UILabel()
    var oldAgeHomeAddressTextField = UITextField()
    
    var adminCityLabel = UILabel()
    var adminCityTextField = UITextField()
    
    var adminZipcodeLabel = UILabel()
    var adminZipcodeTextField = UITextField()
    
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
        loadAdminProfile()
    }

    func setupUI() {
        view.backgroundColor = .white
        
        stackView = UIStackView(arrangedSubviews: [
            createLabelAndTextFieldStack(label: adminNameLabel, textField: adminNameTextField, labelText: "Admin Name"),
            createLabelAndTextFieldStack(label: adminContactNumberLabel, textField: adminContactNumberTextField, labelText: "Contact Number"),
            createLabelAndTextFieldStack(label: oldAgeHomeNameLabel, textField: oldAgeHomeNameTextField, labelText: "Old Age Home Name"),
            createLabelAndTextFieldStack(label: oldAgeHomeAddressLabel, textField: oldAgeHomeAddressTextField, labelText: "Address"),
            createLabelAndTextFieldStack(label: adminCityLabel, textField: adminCityTextField, labelText: "City"),
            createLabelAndTextFieldStack(label: adminZipcodeLabel, textField: adminZipcodeTextField, labelText: "Zipcode")
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
    
    // Helper function to create label and textField stack
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
    
    // Helper function to create buttons
        func createButton(title: String, action: Selector) -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.addTarget(self, action: action, for: .touchUpInside)
            
            // Set button appearance
            button.backgroundColor = UIColor(hex: "#F29E12")  // Custom color
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true  // Set button height
            
            return button
        }

    // Load admin profile from Firestore
    func loadAdminProfile() {
        guard let currentAdmin = Auth.auth().currentUser else { return }
        db.collection("adminsprofile").document(currentAdmin.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                // Set the labels with bold descriptions
                self.adminNameLabel.attributedText = self.createBoldLabelText(boldText: "Admin Name: ", normalText: data?["admin name"] as? String ?? "No Name")
                self.adminContactNumberLabel.attributedText = self.createBoldLabelText(boldText: "Contact Number: ", normalText: data?["contactnumber"] as? String ?? "No Contact")
                self.oldAgeHomeNameLabel.attributedText = self.createBoldLabelText(boldText: "Old Age Home Name: ", normalText: data?["oldagehomename"] as? String ?? "No Old Age Home Name")
                self.oldAgeHomeAddressLabel.attributedText = self.createBoldLabelText(boldText: "Address: ", normalText: data?["oldagehomeaddress"] as? String ?? "No Address")
                self.adminCityLabel.attributedText = self.createBoldLabelText(boldText: "City: ", normalText: data?["city"] as? String ?? "No City")
                self.adminZipcodeLabel.attributedText = self.createBoldLabelText(boldText: "Zipcode: ", normalText: data?["zipcode"] as? String ?? "No Zipcode")
                
                // Update the text fields with plain text from the Firestore document
                self.adminNameTextField.text = data?["admin name"] as? String ?? ""
                self.adminContactNumberTextField.text = data?["contactnumber"] as? String ?? ""
                self.oldAgeHomeNameTextField.text = data?["oldagehomename"] as? String ?? ""
                self.oldAgeHomeAddressTextField.text = data?["oldagehomeaddress"] as? String ?? ""
                self.adminCityTextField.text = data?["city"] as? String ?? ""
                self.adminZipcodeTextField.text = data?["zipcode"] as? String ?? ""
            }
        }
    }

    // Set editing mode
    func setEditingMode(_ isEditing: Bool) {
        isEditingProfile = isEditing
        adminNameLabel.isHidden = isEditing
        adminNameTextField.isHidden = !isEditing
        adminContactNumberLabel.isHidden = isEditing
        adminContactNumberTextField.isHidden = !isEditing
        oldAgeHomeNameLabel.isHidden = isEditing
        oldAgeHomeNameTextField.isHidden = !isEditing
        oldAgeHomeAddressLabel.isHidden = isEditing
        oldAgeHomeAddressTextField.isHidden = !isEditing
        adminCityLabel.isHidden = isEditing
        adminCityTextField.isHidden = !isEditing
        adminZipcodeLabel.isHidden = isEditing
        adminZipcodeTextField.isHidden = !isEditing

        editButton.isHidden = isEditing
        saveButton.isHidden = !isEditing
        cancelButton.isHidden = !isEditing
    }

    // Handle edit button click
    @objc func editButtonClicked() {
        setEditingMode(true)
    }
    
    @objc func cancelButtonClicked() {
        setEditingMode(false)
    }

    @objc func saveButtonClicked() {
        guard let currentAdmin = Auth.auth().currentUser else { return }
        
        let updatedData: [String: Any] = [
            "admin name": adminNameTextField.text ?? "",
            "contactnumber": adminContactNumberTextField.text ?? "",
            "oldagehomename": oldAgeHomeNameTextField.text ?? "",
            "oldagehomeaddress": oldAgeHomeAddressTextField.text ?? "",
            "city": adminCityTextField.text ?? "",
            "zipcode": adminZipcodeTextField.text ?? ""
        ]
        
    let adminDocument = db.collection("adminsprofile").document(currentAdmin.uid)
        
    adminDocument.updateData(updatedData) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                self.adminNameLabel.attributedText = self.createBoldLabelText(boldText: "Admin Name: ", normalText: self.adminNameTextField.text ?? "")
                self.adminContactNumberLabel.attributedText = self.createBoldLabelText(boldText: "Contact Number: ", normalText: self.adminContactNumberTextField.text ?? "")
                self.oldAgeHomeNameLabel.attributedText = self.createBoldLabelText(boldText: "Old Age Home Name: ", normalText: self.oldAgeHomeNameTextField.text ?? "")
                self.oldAgeHomeAddressLabel.attributedText = self.createBoldLabelText(boldText: "Address: ", normalText: self.oldAgeHomeAddressTextField.text ?? "")
                self.adminCityLabel.attributedText = self.createBoldLabelText(boldText: "City: ", normalText: self.adminCityTextField.text ?? "")
                self.adminZipcodeLabel.attributedText = self.createBoldLabelText(boldText: "Zipcode: ", normalText: self.adminZipcodeTextField.text ?? "")
                
                self.setEditingMode(false)
            }
        }
    }

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
