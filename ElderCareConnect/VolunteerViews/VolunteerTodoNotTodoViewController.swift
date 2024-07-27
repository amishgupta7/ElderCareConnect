//
//  TodoNotTodoViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 10/6/24.
//

import UIKit

class VolunteerTodoNotTodoViewController: UIViewController , UITextViewDelegate {
    @IBOutlet weak var toDoNotoDoTextView: UITextView!
    
    @IBOutlet weak var takeTheQuizButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the button initially
        takeTheQuizButton.isEnabled = false
                
        // Set the textView delegate to self
        toDoNotoDoTextView.delegate = self
        
        let dosAndDontsText = """
        ##Please scroll down to read the whole text before the "Take the Quiz" button is enabled.
        
        #Do's:
        ##Communicate Clearly:
        Always speak slowly and clearly when talking to elderly individuals. Make sure they understand what you're saying and give them time to respond.

        ##Be Respectful:
        Treat elderly residents with respect and dignity at all times. They may have different perspectives, and it’s essential to be patient and empathetic.

        ##Offer Assistance:
        Help the elderly with tasks they may find difficult, such as carrying groceries, writing, or navigating their surroundings.

        ##Maintain Confidentiality:
        Any personal information about elderly individuals that you come across must be kept confidential. Do not share any details outside the volunteering context.

        ##Stay Safe:
        Always prioritize your safety and the safety of the elderly. If you're unsure about performing a task safely, ask for help or guidance from the old age home administration.

        ##Report Concerns:
        If you notice anything concerning about the well-being or health of the elderly individual, report it to the home administrators immediately.

        ##Be Punctual:
        Arrive on time for your volunteer shifts and inform the home administration in case of any delays or changes.

        #Don'ts:
        ##Don’t Overstep Boundaries:
        Avoid offering medical or personal advice unless you are specifically trained and authorized to do so.

        ##Don’t Use Phones During Interaction:
        Refrain from using your phone or getting distracted while assisting or spending time with the elderly. Give them your full attention.

        ##Don’t Force Assistance:
        If an elderly person is not comfortable with your help or refuses assistance, respect their wishes unless it's a matter of safety.

        ##Don’t Share Personal Information:
        Avoid sharing your personal details or seeking personal information from the elderly. Keep the interaction professional.

        ##Don’t Undertake Risky Tasks:
        Do not attempt any risky physical tasks (like heavy lifting) that could endanger you or the elderly individual. Always ask for help when needed.
        """
        
        //Format Text for headings
        toDoNotoDoTextView.boldHeadingsInText(dosAndDontsText, fontColor: Global.navcustomColor)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let bottomOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if scrollView.contentOffset.y >= bottomOffset {
                // Enable the button when the user scrolls to the bottom
                takeTheQuizButton.isEnabled = true
            }
        }

}

extension UITextView {
    func boldHeadingsInText(_ text: String, fontColor: UIColor) {
        let normalFont = UIFont.systemFont(ofSize: UIFont.labelFontSize - 3)
        let attributedText = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: normalFont,
            NSAttributedString.Key.foregroundColor: fontColor // Set the color for the entire text
        ])

        let pattern = "(#+)(.*)"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

            for match in matches.reversed() {
                if let _ = Range(match.range(at: 2), in: text) { // Ignore heading content
                    let headingLevel = match.range(at: 1).length // Count of hash symbols
                    let fontSize = headingLevel == 1 ? UIFont.labelFontSize : UIFont.labelFontSize - 3 // Adjust font size based on heading level
                    let boldFont = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
                    let attributes: [NSAttributedString.Key: Any] = [
                        NSAttributedString.Key.font: boldFont,
                        NSAttributedString.Key.foregroundColor: fontColor // Set the color for headings same as the rest of the text
                    ]
                    attributedText.addAttributes(attributes, range: match.range(at: 2))

                    attributedText.replaceCharacters(in: match.range(at: 1), with: "") // Remove #
                }
            }
        } catch {
            print("Error creating regex: \(error)")
        }

        self.attributedText = attributedText
    }
}




