//
//  CustomTabBarController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 9/19/24.
//

import UIKit
import FirebaseAuth
import Firebase

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    let floatingButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let topBackgroundView = UIView()
        topBackgroundView.backgroundColor = UIColor.systemGray6
        topBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBackgroundView)

        NSLayoutConstraint.activate([
             topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
             topBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
         ])
    
        
        setupFloatingSignOutButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setupFloatingSignOutButton() {
        let signOutStackView = UIStackView()
        signOutStackView.axis = .vertical
        signOutStackView.alignment = .center
        signOutStackView.spacing = 2  // Space between icon and text
        signOutStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconButton = UIButton()
        iconButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        iconButton.tintColor = Global.navcustomColor
        
        NSLayoutConstraint.activate([
            iconButton.heightAnchor.constraint(equalToConstant: 30),
            iconButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        iconButton.addTarget(self, action: #selector(changeIconToFilled), for: .touchDown)
        iconButton.addTarget(self, action: #selector(changeIconToRegular), for: [.touchUpInside, .touchUpOutside])

        iconButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)

        // Create a label for the "Sign Out" text
        let signOutLabel = UILabel()
        signOutLabel.text = "Sign Out"
        signOutLabel.textAlignment = .center
        signOutLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        signOutLabel.textColor = Global.navcustomColor
        
        signOutStackView.addArrangedSubview(iconButton)
        signOutStackView.addArrangedSubview(signOutLabel)

        // Add the stack view to the main view
        view.addSubview(signOutStackView)
        
        // Position the stack view at the top-right corner of the screen
        NSLayoutConstraint.activate([
            signOutStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signOutStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10)
        ])
    }

    @objc func changeIconToFilled(_ sender: UIButton) {
        sender.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right.fill"), for: .normal)
    }

    @objc func changeIconToRegular(_ sender: UIButton) {
        sender.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
    }
    
    @objc func signOutTapped() {
        showSignOutConfirmation()
    }

    func showSignOutConfirmation() {
        let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        // "Yes" action triggers the log out process
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.logOutAndNavigateToRoot()  // Proceed with logout
        }
        
        // "No" action cancels the log out
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        // Add actions to the alert controller
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }

    // Log out and navigate to the root controller
    func logOutAndNavigateToRoot() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            showAlert(message: "Error signing out: \(signOutError.localizedDescription)")
            return
        }

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let navigationController = sceneDelegate.window?.rootViewController as? UINavigationController {

            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromRight  // Push to the right
            
            navigationController.view.layer.add(transition, forKey: kCATransition)

            navigationController.popToRootViewController(animated: false)
            
            navigationController.setNavigationBarHidden(false, animated: false)
        }
    }

    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Logout Failed", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
