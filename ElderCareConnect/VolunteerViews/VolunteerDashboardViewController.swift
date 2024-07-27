//
//  VolunteerDashboardViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 9/24/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Charts
import SwiftUI

class VolunteerDashboardTableViewCell: UITableViewCell{
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var serviceTypeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var seniorHomeDetailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var specialNotesLabel: UILabel!
}

struct VolunteerDashboardRequest {
    var requestId: String
    var elderName: String
    var elderAge: Int
    var elderGender: String
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

class VolunteerDashboardViewController: UIViewController , UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var DashboardTableView: UITableView!
    
    var requests = [VolunteerRequest]()
    var filteredRequests = [VolunteerRequest]()
    var adminProfiles: [String: String] = [:]
    var statusCounts: [String: Int] = ["Accepted": 0, "Completed": 0, "Cancelled": 0]
    var selectedStatus: String?
    var stackView: UIStackView!
    var pieChartHostingController: UIHostingController<PieChartView>?

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        DashboardTableView.delegate = self
        DashboardTableView.dataSource = self

        setupStackView()
        selectedStatus = "Accepted"  
        fetchAcceptedRequests()
    }

    func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        setupPieChartView()
        stackView.addArrangedSubview(DashboardTableView)
    }

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
                
                // Reload the table view with filtered data
                DispatchQueue.main.async {
                    self?.DashboardTableView.reloadData()
                }
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



    // Fetch accepted requests from Firestore
    func fetchAcceptedRequests() {
            guard let currentVolunteerId = Auth.auth().currentUser?.uid else {
                print("No current volunteer ID found.")
                return
            }

            db.collection("requests").whereField("volunteerId", isEqualTo: currentVolunteerId).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching requests: \(error)")
                } else if let documents = snapshot?.documents {
                    self.requests.removeAll()
                    var statusTempCounts = ["Accepted": 0, "Completed": 0, "Cancelled": 0]
                    self.requests = documents.map { doc in
                        let data = doc.data()
                        let status = data["status"] as? String ?? "Accpeted"
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
                    self.filterRequests(by: self.selectedStatus ?? "Accepted")
                    self.fetchAdminProfilesForRequests()
                }
            }
    }

    func fetchAdminProfilesForRequests() {
        let dispatchGroup = DispatchGroup()

        for request in requests {
            if adminProfiles[request.adminId] != nil {
                continue
            }

            dispatchGroup.enter()
            db.collection("adminsprofile").document(request.adminId).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching admin profile for adminId \(request.adminId): \(error)")
                } else if let document = document, document.exists {
                    let data = document.data()
                    let oldAgeHomeName = data?["oldagehomename"] as? String ?? "No Name"
                    let oldAgeHomeAddress = data?["oldagehomeaddress"] as? String ?? "No Address"
                    let city = data?["city"] as? String ?? "No City"
                    let zipcode = data?["zipcode"] as? String ?? "No Zip"
                    let seniorHomeDetails = "\(oldAgeHomeName), \(oldAgeHomeAddress), \(city), \(zipcode)"
                    self.adminProfiles[request.adminId] = seniorHomeDetails
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.DashboardTableView.reloadData()
        }
    }

    func filterRequests(by status: String) {
        filteredRequests = requests.filter { $0.status == status }
        
        DispatchQueue.main.async {
            self.DashboardTableView.reloadData()
        }
    }

    func updatePieChart() {
        setupPieChartView()
    }

    // MARK: - UITableView DataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredRequests.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! VolunteerDashboardTableViewCell
        let request = filteredRequests[indexPath.section]
        
        cell.statusLabel.attributedText = createBoldLabelText(boldText: "Status: ", normalText: request.status)
        cell.serviceTypeLabel.attributedText = createBoldLabelText(boldText: "Request Type: ", normalText: request.requestType)
        cell.descriptionLabel.attributedText = createBoldLabelText(boldText: "Description: ", normalText: request.requestDescription)
        cell.dateLabel.attributedText = createBoldLabelText(boldText: "Date & Time: ", normalText: "\(request.requestDate) (\(request.requestFromTime) - \(request.requestToTime))")
        cell.specialNotesLabel.attributedText = createBoldLabelText(boldText: "Special Notes: ", normalText: request.specialNotes)

        if let seniorHomeDetails = adminProfiles[request.adminId] {
            cell.seniorHomeDetailsLabel.attributedText = createBoldLabelText(boldText: "Address: ", normalText: seniorHomeDetails)
        } else {
            cell.seniorHomeDetailsLabel.text = "Fetching senior home address..."
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
        
        let request = filteredRequests[section]
        
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


            // MARK: - Swipe Action for Cancel and Mark a Request complete

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let request = filteredRequests[indexPath.section]

        // Only enable the swipe actions for requests in "Accepted" status
        if request.status == "Accepted" {
            let cancelAction = UIContextualAction(style: .normal, title: "Cancel Request!") { (action, view, completionHandler) in
                let alertController = UIAlertController(title: "Cancel Request", message: "Are you sure you want to cancel this request? Once cancelled, it will be moved from 'My Dashboard' to 'Open Requests'.", preferredStyle: .alert)

                let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                    self.cancelRequest(request: request, at: indexPath)
                }

                let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

                alertController.addAction(yesAction)
                alertController.addAction(noAction)

                self.present(alertController, animated: true, completion: nil)

                completionHandler(true)
            }
            cancelAction.backgroundColor = UIColor.systemRed

            // Complete Action
            let completeAction = UIContextualAction(style: .normal, title: "Mark Complete!") { (action, view, completionHandler) in
                let alertController = UIAlertController(title: "Complete Request", message: "Are you sure you want to mark this request as complete?", preferredStyle: .alert)

                let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                    self.markRequestComplete(request: request, at: indexPath)
                }

                let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

                alertController.addAction(yesAction)
                alertController.addAction(noAction)

                self.present(alertController, animated: true, completion: nil)
                completionHandler(true)
            }
            completeAction.backgroundColor = UIColor.systemGreen

            let configuration = UISwipeActionsConfiguration(actions: [completeAction, cancelAction])
            configuration.performsFirstActionWithFullSwipe = false  // Disable full swipe to allow both actions
            return configuration
        } else {
            return nil
        }
    }



    // MARK: - Cancel Request Logic

    func cancelRequest(request: VolunteerRequest, at indexPath: IndexPath) {
        db.collection("requests").document(request.requestId).updateData([
            "volunteerId": "",
            "status": "Pending",
            "updatedAt": Timestamp()
        ]) { error in
            if let error = error {
                print("Error cancelling request: \(error.localizedDescription)")
            } else {
                print("Request successfully cancelled!")

                // Safely remove the request from both the requests and filteredRequests arrays
                self.requests.removeAll { $0.requestId == request.requestId }
                self.filteredRequests.remove(at: indexPath.section)

                // Update status counts: decrease 'Accepted'
                if let acceptedCount = self.statusCounts["Accepted"], acceptedCount > 0 {
                    self.statusCounts["Accepted"] = acceptedCount - 1
                }

                // Update the pie chart with the new counts
                self.updatePieChart()

                // Reload the table view after the change
                if self.filteredRequests.isEmpty {
                    self.DashboardTableView.reloadData()
                } else {
                    self.DashboardTableView.performBatchUpdates({
                        self.DashboardTableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    }, completion: { _ in
                        self.DashboardTableView.reloadData()
                    })
                }
            }
        }
    }

    // MARK: - Mark Request Complete Logic

    func markRequestComplete(request: VolunteerRequest, at indexPath: IndexPath) {
        db.collection("requests").document(request.requestId).updateData([
            "status": "Completed",
            "updatedAt": Timestamp()
        ]) { error in
            if let error = error {
                print("Error marking request complete: \(error.localizedDescription)")
            } else {
                print("Request successfully marked complete!")

                // Safely remove the request from the Accepted status in both arrays
                self.requests.removeAll { $0.requestId == request.requestId }
                self.filteredRequests.remove(at: indexPath.section)

                // Update status counts: decrease 'Accepted' and increase 'Completed'
                if let acceptedCount = self.statusCounts["Accepted"], acceptedCount > 0 {
                    self.statusCounts["Accepted"] = acceptedCount - 1
                }
                if let completedCount = self.statusCounts["Completed"] {
                    self.statusCounts["Completed"] = completedCount + 1
                }

                // Update the pie chart with the new counts
                self.updatePieChart()

                var updatedRequest = request
                updatedRequest.status = "Completed"
                self.requests.append(updatedRequest)
                
                if self.selectedStatus == "Completed" {
                    self.filterRequests(by: "Completed")
                }

                // Reload the table view after the change
                if self.filteredRequests.isEmpty {
                    self.DashboardTableView.reloadData()
                } else {
                    self.DashboardTableView.performBatchUpdates({
                        self.DashboardTableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    }, completion: { _ in
                        self.DashboardTableView.reloadData()
                    })
                }
            }
        }
    }



    override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                fetchAcceptedRequests()
        }
    }
    
    
