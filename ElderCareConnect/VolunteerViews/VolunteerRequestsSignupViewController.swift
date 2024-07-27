//
//  VolunteerRequestsSignupViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 8/16/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class OpenRequestTableViewCell: UITableViewCell {
    @IBOutlet weak var serviceTypeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var seniorHomeDetailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var specialNotesLabel: UILabel!

}

struct VolunteerRequest {
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

class VolunteerRequestsSignupViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var requests = [VolunteerRequest]()
    var adminProfiles: [String: String] = [:]  

      let db = Firestore.firestore()

      override func viewDidLoad() {
          super.viewDidLoad()
          tableView.delegate = self
          tableView.dataSource = self
          tableView.estimatedRowHeight = 80
          tableView.rowHeight = UITableView.automaticDimension
          
          tableView.estimatedSectionHeaderHeight = 10
          fetchPendingRequests()
      }

      // Fetch pending requests from Firestore
      func fetchPendingRequests() {
          db.collection("requests").whereField("status", isEqualTo: "Pending").getDocuments { (snapshot, error) in
              if let error = error {
                  print("Error fetching requests: \(error)")
              } else {
                  if let documents = snapshot?.documents {
                      self.requests = documents.map { doc in
                          let data = doc.data()
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
                              status: data["status"] as? String ?? "Pending",
                              adminId: data["adminId"] as? String ?? "",
                              volunteerId: data["volunteerId"] as? String ?? ""
                          )
                      }
                      self.fetchAdminProfilesForRequests()
                  }
              }
          }
      }

      // Fetch admin profile details for each request based on adminId
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
                      
                      // Combine the details into one field
                      let seniorHomeDetails = "\(oldAgeHomeName), \(oldAgeHomeAddress), \(city), \(zipcode)"
                      
                      // Store the senior home details in the dictionary using adminId as the key
                      self.adminProfiles[request.adminId] = seniorHomeDetails
                  }
                  dispatchGroup.leave()
              }
          }

          dispatchGroup.notify(queue: .main) {
              self.tableView.reloadData()
          }
      }

      // MARK: - UITableView DataSource methods

      func numberOfSections(in tableView: UITableView) -> Int {
          return requests.count
      }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 1
      }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! OpenRequestTableViewCell
          let request = requests[indexPath.section]
          cell.serviceTypeLabel.attributedText = createBoldLabelText(boldText: "Request Type: ", normalText: request.requestType)
          cell.descriptionLabel.attributedText = createBoldLabelText(boldText: "Description: ", normalText: request.requestDescription)
          cell.dateLabel.attributedText = createBoldLabelText(
              boldText: "Date & Time: ",
              normalText: "\(request.requestDate) (\(request.requestFromTime) - \(request.requestToTime))"
          )
          cell.specialNotesLabel.attributedText = createBoldLabelText(boldText: "Special Notes: ", normalText: request.specialNotes)
          
          if let seniorHomeDetails = adminProfiles[request.adminId] {
              cell.seniorHomeDetailsLabel.attributedText = createBoldLabelText(boldText: "Address: ", normalText: seniorHomeDetails)
          } else {
              cell.seniorHomeDetailsLabel.text = "Fetching senior home address..."
          }

          
          return cell
      }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Global.tabelviewheadercolor
        
        // Create a label for the header title
        let headerLabel = UILabel()
        headerLabel.text = "Request for \(requests[section].elderName), \(requests[section].eldergender), \(requests[section].elderAge)"
        headerLabel.textColor = Global.navcustomColor
        //headerLabel.font = UIFont.systemFont(ofSize: 15)
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
    
    // MARK: - Swipe Action for Accepting a Request

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let request = requests[indexPath.section]
        
        let acceptAction = UIContextualAction(style: .normal, title: "Accept Request!") { (action, view, completionHandler) in

            let alertController = UIAlertController(title: "Confirm Acceptance", message: "Are you sure you want to accept this request? Once accepted, it will be moved from 'Open Requests' to 'My Dashboard'.", preferredStyle: .alert)

            // Yes action
            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                self.acceptRequest(request: request, at: indexPath)
            }
            
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
            completionHandler(true)
        }

        acceptAction.backgroundColor = UIColor.systemGreen  // Customize the color of the action
        let configuration = UISwipeActionsConfiguration(actions: [acceptAction])
        return configuration
    }

    // MARK: - Accept Request Logic

    func acceptRequest(request: VolunteerRequest, at indexPath: IndexPath) {
        guard let currentVolunteer = Auth.auth().currentUser else {
            print("No volunteer logged in")
            return
        }

        let volunteerId = currentVolunteer.uid

        // Update Firestore with the accepted request details
        db.collection("requests").document(request.requestId).updateData([
            "volunteerId": volunteerId,
            "status": "Accepted",
            "updatedAt": Timestamp()
        ]) { error in
            if let error = error {
                print("Error accepting request: \(error.localizedDescription)")
            } else {
                print("Request successfully accepted!")
                self.requests.remove(at: indexPath.section)
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPendingRequests()
    }

  }
