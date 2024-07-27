//
//  VolunteerQuizViewController.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 09/18/24.
//

import UIKit

var quizStructure: [(
    question: String,
    answers: [String],
    correctAnswer: Int
)] = []

class VolunteerQuizViewController: UIViewController {

    // This will store the current question we are working with
       var vQuestion: (question: String, answers: [String], correctAnswer: Int)!
       
       // amount of points user has
       var userScore: Int = 0
       var isRetakingQuiz = false
       var answerSelected: Int = -1
       
       // label keeping track of score
       @IBOutlet weak var scoreLabel: UILabel!
       // label displaying the question
       @IBOutlet weak var questionLabel: UILabel!
       // outlets to set answer text 
       @IBOutlet weak var answerAoutlet: UIButton!
       @IBOutlet weak var answerBoutlet: UIButton!
       @IBOutlet weak var answerCoutlet: UIButton!
       @IBOutlet weak var answerDoutlet: UIButton!
       @IBOutlet weak var nextQuestionButton: UIButton!
       @IBOutlet weak var Answer: UILabel!
       @IBOutlet weak var registerNowButton: UIButton!
    
       override func viewDidLoad() {
           super.viewDidLoad()
           quizStructure = volunteerQuizStructure
           nextQuestionButton.isHidden = false;
           newQuestion()

           questionLabel.numberOfLines = 0
           // to wrap the label's text by word instead of by character
           questionLabel.lineBreakMode = .byWordWrapping
           registerNowButton.isEnabled = false

       }

       
       @IBAction func answerAclicked(_ sender: Any) {
           if isRetakingQuiz {
               restartQuiz()
            } else {
                checkAnswer(selectedAnswer: 0)
            }
       }
       
       @IBAction func answerBclicked(_ sender: Any) {
           checkAnswer(selectedAnswer: 1)
       }
       
       @IBAction func answerCclicked(_ sender: Any) {
           checkAnswer(selectedAnswer: 2)
       }
       
       @IBAction func answerDclicked(_ sender: Any) {
           checkAnswer(selectedAnswer: 3)
       }

       @IBAction func nextQuestion(_ sender: Any) {
           if answerSelected == -1 {
               Answer.textColor = UIColor.blue
               Answer.text = "Please select your Answer to Continue!"
           }
           else {
               newQuestion()
           }
           answerSelected = -1
       }
       

       
       // quiz data structure with question, answers, and corresponding correct answer
       // correctAnswer is the index in the answers for the correct answer
    var volunteerQuizStructure = [
        (
            question: "Q1. What is the most important thing to remember when communicating with elderly individuals?",
            answers: [
                "Talk as fast as possible to save time",
                "Use complex medical terms",
                "Speak slowly and clearly, giving them time to respond",
                "Use text messages instead of speaking"
            ],
            correctAnswer: 2
        ),
        (
            question: "Q2. Which of the following is a key responsibility of a volunteer?",
            answers: [
                "Providing financial advice to the elderly",
                "Sharing their personal problems",
                "Reporting any concerns about the elderly's well-being to the administration",
                "Ignoring complaints from the elderly"
            ],
            correctAnswer: 2
        ),
        (
            question: "Q3. Which of these is a 'Don't' for volunteers?",
            answers: [
                "Offering assistance with tasks",
                "Using your phone while spending time with the elderly",
                "Being respectful and patient",
                "Maintaining confidentiality"
            ],
            correctAnswer: 1
        ),
        (
            question: "Q4. If an elderly person refuses your help, what should you do?",
            answers: [
                "Force them to accept your assistance",
                "Respect their wishes unless it's a safety concern",
                "Insist that they follow your advice",
                "Leave immediately without saying anything"
            ],
            correctAnswer: 1
        ),
        (
            question: "Q5. What should you do if you’re unsure about the safety of a task you’ve been asked to do?",
            answers: [
                "Attempt the task regardless of the risks",
                "Refuse the task without explanation",
                "Ask for guidance or help from the old age home administration",
                "Delegate the task to another volunteer"
            ],
            correctAnswer: 2
        )
    ]

    func checkAnswer(selectedAnswer: Int) {
           if selectedAnswer == vQuestion.correctAnswer {
               let darkGreen = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
               Answer.textColor = darkGreen
               Answer.text = "Correct Answer!"
               userScore += 10
           } else {
               Answer.textColor = UIColor.red
               Answer.text = "Incorrect. The correct answer is: \(vQuestion.answers[vQuestion.correctAnswer])"
           }
           scoreLabel.text = "Your Score: \(userScore) / 50"
           disableAnswerButtons()
           answerSelected = selectedAnswer
       }

       func newQuestion() {
           enableAnswerButtons()
           Answer.text = ""
          
           if !quizStructure.isEmpty {
               vQuestion = quizStructure.removeFirst()
               questionLabel.text = vQuestion.question
               answerAoutlet.setTitle(vQuestion.answers[0], for: .normal)
               answerBoutlet.setTitle(vQuestion.answers[1], for: .normal)
               answerCoutlet.setTitle(vQuestion.answers[2], for: .normal)
               answerDoutlet.setTitle(vQuestion.answers[3], for: .normal)
           } else {
               endQuiz()
           }
       }

       func disableAnswerButtons() {
           answerAoutlet.isEnabled = false
           answerBoutlet.isEnabled = false
           answerCoutlet.isEnabled = false
           answerDoutlet.isEnabled = false
       }

    func enableAnswerButtons() {
           answerAoutlet.isEnabled = true
           answerAoutlet.isHidden = false
           answerBoutlet.isEnabled = true
           answerBoutlet.isHidden = false
           answerCoutlet.isEnabled = true
           answerCoutlet.isHidden = false
           answerDoutlet.isEnabled = true
           answerDoutlet.isHidden = false
           nextQuestionButton.isHidden = false
       }

       func endQuiz() {
           if userScore >= 40 {
               questionLabel.text = "Well done! You’ve qualified. Please click the Register Now button to complete your registration."
               answerAoutlet.isHidden = true
               registerNowButton.isEnabled = true
           } else {
               questionLabel.text = "Good effort! You need at least 4 correct answers to qualify. Please try again to complete your registration."
               answerAoutlet.setTitle("Retake the quiz!", for: .normal)
               isRetakingQuiz = true
           }
           nextQuestionButton.isHidden = true
           answerBoutlet.isHidden = true
           answerCoutlet.isHidden = true
           answerDoutlet.isHidden = true
       }

       func restartQuiz() {
           userScore = 0
           scoreLabel.text = "Your Score: \(userScore) / 50"
           quizStructure = volunteerQuizStructure
           isRetakingQuiz = false
           newQuestion()
           
       }

   }



