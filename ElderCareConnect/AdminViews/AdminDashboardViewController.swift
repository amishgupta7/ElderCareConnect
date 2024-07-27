//
//  AdminDashboardViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 8/14/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Charts
import SwiftUI

class AdminDashboardTableViewCell: UITableViewCell{
    @IBOutlet weak var serviceTypeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var volunteerName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var status: UILabel!
}

struct AdminDashboardRequest {
    var requestId: String
    var elderName: String
    var elderAge: Int
    var eldergender: String
    var requestType: String
    var requestDescription: String
    var requestDate: String
    var requestFromTime: String
    var requestToTime: String
    var specialNotes: String
    var status: String
    var adminId: String
    var volunteerId: String
}

class AdminDashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var AdminDashboardTableView: UITableView!
    
     var requests = [VolunteerRequest]()
     var filteredRequests = [VolunteerRequest]()
     var volunteerProfiles: [String: String] = [:]  // Dictionary to store volunteer names with volunteerId as key

     var statusCounts: [String: Int] = ["Accepted": 0, "Completed": 0, "Pending": 0,  "Cancelled": 0]
     var selectedStatus: String? 
     var stackView: UIStackView!
    var pieChartHostingController: UIHostingController<PieChartView>?
     let db = Firestore.firestore()
    
     override func viewDidLoad() {
         super.viewDidLoad()
         
         AdminDashboardTableView.delegate = self
         AdminDashboardTableView.dataSource = self

                setupStackView()
                fetchRequests()
            }

    // Setup Stack View
    func setupStackView() {
        // Initialize stack view
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        // Add constraints to stack view to fit the full screen
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add pie chart and table view to the stack view
        setupPieChartView()
        stackView.addArrangedSubview(AdminDashboardTableView)
    }

    // Setup Pie Chart
    func setupPieChartView() {
        if let pieChartHostingController = pieChartHostingController {
            pieChartHostingController.view.removeFromSuperview()
            pieChartHostingController.removeFromParent()
        }

        // Create PieChartView and highlight "Accepted" by default
        pieChartHostingController = UIHostingController(rootView: PieChartView(
            statusCounts: statusCounts,
            onSelectStatus: { [weak self] selectedStatus in
                self?.selectedStatus = selectedStatus
                self?.filterRequests(by: selectedStatus)
            },
            initialHighlight: "Accepted" // Highlight "Accepted" by default
        ))
        
        guard let pieChartView = pieChartHostingController?.view else { return }
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertArrangedSubview(pieChartView, at: 0)
        pieChartView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        addChild(pieChartHostingController!)
        pieChartHostingController?.didMove(toParent: self)
    }




    // Fetch requests from Firestore
    func fetchRequests() {
        statusCounts = ["Accepted": 0, "Completed": 0, "Pending": 0, "Cancelled": 0]

        db.collection("requests").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching requests: \(error)")
            } else if let documents = snapshot?.documents {
                self.requests.removeAll()

                var statusTempCounts = ["Accepted": 0, "Completed": 0, "Pending": 0, "Cancelled": 0]

                self.requests = documents.compactMap { doc in
                    let data = doc.data()
                    let status = data["status"] as? String ?? "Pending"

                    // Safely update status count
                    if statusTempCounts[status] != nil {
                        statusTempCounts[status]! += 1
                    }

                    return VolunteerRequest(
                        requestId: doc.documentID,
                        elderName: data["elderName"] as? String ?? "No Name",
                        elderAge: data["elderAge"] as? Int ?? 0,
                        eldergender: data["gender"] as? String ?? "No Gender",
                        requestType: data["requestType"] as? String ?? "No Type",
                        requestDescription: data["description"] as? String ?? "No Description",
                        requestDate: data["requestDate"] as? String ?? "No Date",
                        requestFromTime: data["requestFromTime"] as? String ?? "No From Time",
                        requestToTime: data["requestToTime"] as? String ?? "No To Time",
                        specialNotes: data["specialnotes"] as? String ?? "No Notes",
                        status: status,
                        adminId: data["adminId"] as? String ?? "",
                        volunteerId: data["volunteerId"] as? String ?? ""
                    )
                }

                self.statusCounts = statusTempCounts
                self.updatePieChart()

                // Filter the requests based on selected status and reload the table view
                self.filterRequests(by: self.selectedStatus ?? "Pending")
                self.fetchVolunteerProfilesForRequests()

                // This ensures the table view is updated as soon as data changes
                self.AdminDashboardTableView.reloadData()
            }
        }
    }


    func updatePieChart() {
        setupPieChartView()
    }

    // Fetch volunteer profile details for each request based on volunteerId
    func fetchVolunteerProfilesForRequests() {
        let dispatchGroup = DispatchGroup()

        for request in requests {
            if !request.volunteerId.isEmpty, volunteerProfiles[request.volunteerId] == nil {
                dispatchGroup.enter()

                // Fetch volunteer profile based on volunteerId
                db.collection("volunteersprofile").document(request.volunteerId).getDocument { (document, error) in
                    if let error = error {
                        print("Error fetching volunteer profile for volunteerId \(request.volunteerId): \(error)")
                    } else if let document = document, document.exists {
                        let data = document.data()
                        let volunteerName = data?["name"] as? String ?? "No Name"
                        
                        // Ensure the dictionary is updated with the correct volunteerId
                        self.volunteerProfiles[request.volunteerId] = volunteerName
                    }
                    dispatchGroup.leave()
                }
            }
        }

        // Reload table view once all profiles are fetched
        dispatchGroup.notify(queue: .main) {
            self.AdminDashboardTableView.reloadData()
        }
    }


    // Filter requests by status
    func filterRequests(by status: String) {
        filteredRequests = requests.filter { $0.status == status }
        AdminDashboardTableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredRequests.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! AdminDashboardTableViewCell

        let request = filteredRequests[indexPath.section]

        cell.serviceTypeLabel.attributedText = createBoldLabelText(boldText: "Request Type: ", normalText: request.requestType)
        cell.descriptionLabel.attributedText = createBoldLabelText(boldText: "Description: ", normalText: request.requestDescription)
        cell.dateLabel.attributedText = createBoldLabelText(
            boldText: "Date & Time: ",
            normalText: "\(request.requestDate) (\(request.requestFromTime) - \(request.requestToTime))"
        )
        cell.status.attributedText = createBoldLabelText(boldText: "Status: ", normalText: request.status)
        
        // Check if a volunteer is assigned and display their name, otherwise show "Not Assigned"
        if let volunteerName = volunteerProfiles[request.volunteerId], !volunteerName.isEmpty {
            cell.volunteerName.attributedText = createBoldLabelText(boldText: "Volunteer Name: ", normalText: volunteerName)
        } else {
            cell.volunteerName.attributedText = createBoldLabelText(boldText: "Volunteer Name: ", normalText: "Not Assigned")
        }

        return cell
    }


    func createBoldLabelText(boldText: String, normalText: String) -> NSAttributedString {
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14)]
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        let boldString = NSMutableAttributedString(string: boldText, attributes: boldAttributes)
        let normalString = NSAttributedString(string: normalText, attributes: normalAttributes)
        boldString.append(normalString)
        return boldString
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Global.tabelviewheadercolor
        
        // Use filteredRequests instead of requests
        let request = filteredRequests[section]
        
        // Create a label for the header title
        let headerLabel = UILabel()
        headerLabel.text = "Request for \(request.elderName), \(request.eldergender), \(request.elderAge)"
        headerLabel.textColor = Global.navcustomColor
        headerLabel.font = UIFont(name: "Noteworthy-Bold", size: 15) ?? UIFont.systemFont(ofSize: 16)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let request = filteredRequests[indexPath.section] // Use filteredRequests instead of requests for filtered data

        // Only allow the Edit action for requests with status "Accepted" or "Pending"
        if request.status == "Accepted" || request.status == "Pending" {
            let editAction = UIContextualAction(style: .normal, title: "Edit Request") { (action, view, completionHandler) in
                
                let alertController = UIAlertController(title: "Edit Request", message: "Edit the details of the request below.", preferredStyle: .alert)
                
                // Add text fields to edit each request property
                alertController.addTextField { textField in
                    textField.text = request.elderName
                    textField.placeholder = "Elder Name"
                }
                
                alertController.addTextField { textField in
                    textField.text = "\(request.elderAge)"
                    textField.placeholder = "Elder Age"
                    textField.keyboardType = .numberPad
                }
                
                alertController.addTextField { textField in
                    textField.text = request.requestType
                    textField.placeholder = "Request Type"
                }
                
                alertController.addTextField { textField in
                    textField.text = request.requestDescription
                    textField.placeholder = "Description"
                }
                
                alertController.addTextField { textField in
                    textField.text = request.requestDate
                    textField.placeholder = "Request Date (YYYY-MM-DD)"
                }
                
                alertController.addTextField { textField in
                    textField.text = request.requestFromTime
                    textField.placeholder = "From Time (HH:mm)"
                }
                
                alertController.addTextField { textField in
                    textField.text = request.requestToTime
                    textField.placeholder = "To Time (HH:mm)"
                }
                
                alertController.addTextField { textField in
                    textField.text = request.specialNotes
                    textField.placeholder = "Special Notes"
                }

                // Add a picker or text field to update the status
                alertController.addTextField { textField in
                    textField.text = request.status
                    textField.placeholder = "Status (Pending, Accepted, Completed, Cancelled)"
                }

                let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                    let updatedElderName = alertController.textFields?[0].text ?? request.elderName
                    let updatedElderAge = Int(alertController.textFields?[1].text ?? "\(request.elderAge)") ?? request.elderAge
                    let updatedRequestType = alertController.textFields?[2].text ?? request.requestType
                    let updatedDescription = alertController.textFields?[3].text ?? request.requestDescription
                    let updatedRequestDate = alertController.textFields?[4].text ?? request.requestDate
                    let updatedFromTime = alertController.textFields?[5].text ?? request.requestFromTime
                    let updatedToTime = alertController.textFields?[6].text ?? request.requestToTime
                    let updatedSpecialNotes = alertController.textFields?[7].text ?? request.specialNotes
                    let updatedStatus = alertController.textFields?[8].text ?? request.status  // Status field

                    self.editRequest(
                        requestId: request.requestId,
                        updatedElderName: updatedElderName,
                        updatedElderAge: updatedElderAge,
                        updatedRequestType: updatedRequestType,
                        updatedDescription: updatedDescription,
                        updatedRequestDate: updatedRequestDate,
                        updatedFromTime: updatedFromTime,
                        updatedToTime: updatedToTime,
                        updatedSpecialNotes: updatedSpecialNotes,
                        updatedStatus: updatedStatus
                    )
                    
                    completionHandler(true)  // Indicate the action was performed
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(saveAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }

            editAction.backgroundColor = UIColor.systemBlue  // Customize the color of the action
            let configuration = UISwipeActionsConfiguration(actions: [editAction])
            return configuration
        } else {
            return nil
        }
    }

    // MARK: - Edit Request Logic

    func editRequest(
        requestId: String,
        updatedElderName: String,
        updatedElderAge: Int,
        updatedRequestType: String,
        updatedDescription: String,
        updatedRequestDate: String,
        updatedFromTime: String,
        updatedToTime: String,
        updatedSpecialNotes: String,
        updatedStatus: String
    ) {
        db.collection("requests").document(requestId).updateData([
            "elderName": updatedElderName,
            "elderAge": updatedElderAge,
            "requestType": updatedRequestType,
            "description": updatedDescription,
            "requestDate": updatedRequestDate,
            "requestFromTime": updatedFromTime,
            "requestToTime": updatedToTime,
            "specialnotes": updatedSpecialNotes,
            "status": updatedStatus,
            "updatedAt": Timestamp()
        ]) { error in
            if let error = error {
                print("Error updating request: \(error.localizedDescription)")
            } else {
                print("Request successfully updated!")
                self.fetchRequests()
            }
        }
    }


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchRequests()
    }
}
