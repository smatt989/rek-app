//
//  SignUpViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/23/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class SignUpViewController: UIFormViewController {
    
    private var tryingToCreateAccount = false


    @IBOutlet weak var usernameInput: UITextField!

    @IBOutlet weak var emailInput: UITextField!
    
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var passwordConfirmInput: UITextField!
    
    @IBOutlet weak var alertText: UITextView!

    @IBAction func createAccount(_ sender: UIButton) {
        if let username = usernameInput.text, let email = emailInput.text, let password = passwordInput.text, let passwordConfirm = passwordConfirmInput.text {
            let userCreate = UserCreate(username: username, email: email, password: password)
            if validSignup(userCreate: userCreate, confirmPassword: passwordConfirm) && !tryingToCreateAccount{
                tryingToCreateAccount = true
                User.signUp(newUser: userCreate, success: createAccountSuccess, failure: createAccountFailure)
            } else {
                tryingToCreateAccount = false
                cleanFormWithAlert(alert: "All fields must be filled in, password must have at least 6 characters")
            }
        }
    }
    
    private func validSignup(userCreate: UserCreate, confirmPassword: String) -> Bool {
        return validUserName(userCreate.username) && validEmail(userCreate.email) && validPassword(userCreate.password) &&
            validPasswordMatch(confirmPassword, password: userCreate.password)
    }
    
    private func validUserName(_ name: String) -> Bool {
        return name.characters.count > 2
    }
    
    private func validPassword(_ password: String) -> Bool {
        return password.characters.count > 5
    }
    
    private func validPasswordMatch(_ passwordMatch: String, password: String) -> Bool {
        return passwordMatch == password
    }
    
    private func validEmail(_ email: String) -> Bool {
        return email.characters.count > 5 && email.contains("@") && email.contains(".")
    }
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private func createAccountSuccess(user: User) {
        tryingToCreateAccount = false
        appDelegate.loginFailure()
    }
    
    private func createAccountFailure(error: Error) {
        tryingToCreateAccount = false
        cleanFormWithAlert(alert: error.localizedDescription)
    }
    
    private func cleanFormWithAlert(alert: String?) {
        alertText.text = alert
        alertText.isHidden = alert == nil
        usernameInput.text = ""
        emailInput.text = ""
        passwordInput.text = ""
        passwordConfirmInput.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cleanFormWithAlert(alert: nil)
    }
    
    
    
}
