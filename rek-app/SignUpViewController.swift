//
//  SignUpViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/23/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class SignUpViewController: UIFormViewController, UITextFieldDelegate {
    
    var managedObjectContext =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    private var tryingToCreateAccount = false
    
    private var usernameErrorMessage: String? {
        didSet {
            setupAlertForInputValue(usernameCreate, input: usernameInput, label: usernameAlertText, alert: usernameErrorMessage)
        }
    }
    
    private func setupAlertForInputValue(_ value: String?, input: UITextField, label: UILabel, alert: String?) {
        if let error = alert {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.textFieldInvalid(input)
                label.text = error
                label.isHidden = false
            }
        } else {
            DispatchQueue.main.async { [weak weakself = self] in
                label.isHidden = true
                if value != nil && value! != "" {
                    weakself?.textFieldValid(input)
                } else {
                    weakself?.textFieldBorderColor(input, color: UIColor.clear.cgColor)
                }
            }
        }
    }
    
    private var emailErrorMessage: String? {
        didSet {
            setupAlertForInputValue(emailCreate, input: emailInput, label: emailAlertText, alert: emailErrorMessage)
        }
    }
    
    private var passwordErrorMessage: String? {
        didSet {
            setupAlertForInputValue(passwordCreate, input: passwordInput, label: passwordAlertText, alert: passwordErrorMessage)
        }
    }
    
    private var passwordConfirmErrorMessage: String? {
        didSet {
            setupAlertForInputValue(passwordConfirm, input: passwordConfirmInput, label: passwordConfirmAlertText, alert: passwordConfirmErrorMessage)
        }
    }
    
    private var usernameCreate: String? {
        didSet {
            if let str = usernameCreate, str != "" {
                if !validUserName(str) {
                    usernameErrorMessage = "Must be at least 3 characters"
                } else {
                    User.validateUsername(username: str, success: {[weak weakself = self] bool in
                        if !bool {
                            weakself?.usernameErrorMessage = "Username already taken"
                        } else {
                            weakself?.usernameErrorMessage = nil
                        }
                        weakself?.colorCreateAccountButton()
                        }, failure: {err in
                            print(err)
                    })
                }
            } else {
                usernameErrorMessage = nil
            }
            colorCreateAccountButton()
        }
    }
    
    private var emailCreate: String? {
        didSet {
            if let str = emailCreate, str != "" {
                if !validEmail(str) {
                    emailErrorMessage = "Must be valid email"
                } else {
                    User.validateEmail(email: str, success: {[weak weakself = self] bool in
                        if !bool {
                            weakself?.emailErrorMessage = "Email used by another account"
                        } else {
                            weakself?.emailErrorMessage = nil
                        }
                        weakself?.colorCreateAccountButton()
                        }, failure: {err in
                            print(err)
                    })
                }
            } else {
                emailErrorMessage = nil
            }
            colorCreateAccountButton()
        }
    }
    
    private var passwordCreate: String? {
        didSet {
            if let str = passwordCreate, str != "" {
                if !validPassword(str) {
                    passwordErrorMessage = "Must be at least 6 characters"
                } else {
                    passwordErrorMessage = nil
                }
            } else {
                passwordErrorMessage = nil
            }
            colorCreateAccountButton()
        }
    }
    
    private var passwordConfirm: String? {
        didSet {
            if let str = passwordConfirm, str != "" {
                if passwordCreate == str {
                    passwordConfirmErrorMessage = nil
                } else {
                    passwordConfirmErrorMessage = "Must match password"
                }
            } else {
                passwordConfirmErrorMessage = nil
            }
            colorCreateAccountButton()
        }
    }

    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var passwordConfirmInput: UITextField!
    
    @IBOutlet weak var usernameAlertText: UILabel!
    @IBOutlet weak var emailAlertText: UILabel!
    @IBOutlet weak var passwordAlertText: UILabel!
    @IBOutlet weak var passwordConfirmAlertText: UILabel!

    @IBOutlet weak var createAccountButton: UIButton!
   
    @IBAction func createAccount(_ sender: UIButton) {
        if validForm() {
            tryingToCreateAccount = true
            let userCreate = UserCreate(username: usernameCreate!, email: emailCreate!, password: passwordCreate!)
            User.signUp(newUser: userCreate, success: createAccountSuccess, failure: createAccountFailure)
        } else {
            tryingToCreateAccount = false
            cleanFormWithAlert(alert: "All fields must be filled in, password must have at least 6 characters")
        }
    }
    
    private func validForm() -> Bool {
        if let username = usernameCreate, let email = emailCreate, let password = passwordCreate, let pwConfirm = passwordConfirm {
            let userCreate = UserCreate(username: username, email: email, password: password)
            return validSignup(userCreate: userCreate, confirmPassword: pwConfirm)
        } else {
            return false
        }
    }
    
    private func validSignup(userCreate: UserCreate, confirmPassword: String) -> Bool {
        return validUserName(userCreate.username) && validEmail(userCreate.email) && validPassword(userCreate.password) &&
            validPasswordMatch(confirmPassword, password: userCreate.password) && usernameErrorMessage == nil && emailErrorMessage == nil
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
        User.login(username: user.username,
                   password: passwordInput.text!,
                   managedObjectContext: managedObjectContext!,
                   success: {[weak weakself = self] _ in
                    weakself?.appDelegate.routeGivenAuthentication()
                    },
                   failure: {[weak weakself = self] _ in
                    weakself?.appDelegate.loginFailure()
                    })
    }
    
    private func createAccountFailure(error: Error) {
        tryingToCreateAccount = false
        cleanFormWithAlert(alert: error.localizedDescription)
    }
    
    private func setupForm() {
        usernameInput.returnKeyType = .done
        emailInput.returnKeyType = .done
        passwordInput.returnKeyType = .done
        passwordConfirmInput.returnKeyType = .done
    }
    
    private func cleanFormWithAlert(alert: String?) {
        usernameInput.text = ""
        emailInput.text = ""
        passwordInput.text = ""
        passwordConfirmInput.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cleanFormWithAlert(alert: nil)
        resetFormAlerts()
        makeListeners()
        usernameInput.delegate = self
        emailInput.delegate = self
        passwordInput.delegate = self
        passwordConfirmInput.delegate = self
        setupForm()
        colorCreateAccountButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeners()
    }
    
    private func makeListeners() {
        listenToUsername()
        listenToEmail()
        listenToPassword()
        listenToPasswordConfirm()
    }
    
    private func stopListeners() {
        stopListener(usernameListener)
        stopListener(emailListener)
        stopListener(passwordListener)
        stopListener(passwordConfirmListener)
    }
    
    private func resetFormAlerts() {
        usernameAlertText.isHidden = true
        emailAlertText.isHidden = true
        passwordAlertText.isHidden = true
        passwordConfirmAlertText.isHidden = true
    }
    
    private var usernameListener: NSObjectProtocol?
    private var emailListener: NSObjectProtocol?
    private var passwordListener: NSObjectProtocol?
    private var passwordConfirmListener: NSObjectProtocol?
    
    private func makeListener(_ textField: UITextField, updateFunction: @escaping (String?) -> Void) -> NSObjectProtocol {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        return center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: textField,
            queue: queue) { notification in
                updateFunction(textField.text)
        }
    }
    
    private func stopListener(_ listener: NSObjectProtocol?) {
        if let observer = listener {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func listenToUsername() {
        usernameListener = makeListener(usernameInput) { [weak weakself = self] str in
            weakself?.usernameCreate = str
        }
    }
    
    private func listenToEmail() {
        emailListener = makeListener(emailInput) { [weak weakself = self] str in
            weakself?.emailCreate = str
        }
    }
    
    private func listenToPassword() {
        passwordListener = makeListener(passwordInput) { [weak weakself = self] str in
            weakself?.passwordCreate = str
        }
    }
    
    private func listenToPasswordConfirm() {
        passwordConfirmListener = makeListener(passwordConfirmInput) { [weak weakself = self] str in
            weakself?.passwordConfirm = str
        }
    }
    
    private var validColor: CGColor {
        get {
            return enabledColor.cgColor
        }
    }
    private let invalidColor = UIColor(colorLiteralRed: 0.86, green:0.38, blue:0.51, alpha:1.0).cgColor
    
    private let disabledColor = UIColor(colorLiteralRed:0.62, green:0.62, blue:0.62, alpha:1.0)
    private let enabledColor = UIColor(colorLiteralRed:0.37, green:0.80, blue:0.59, alpha:1.0)
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    private func textFieldInvalid(_ textField: UITextField) {
        textFieldBorderColor(textField, color: invalidColor)
    }
    
    private func textFieldValid(_ textField: UITextField) {
        textFieldBorderColor(textField, color: validColor)
    }
    
    private func colorCreateAccountButton() {
        if validForm() {
            uiButtonEnabled(createAccountButton)
        } else {
            uiButtonDisabled(createAccountButton)
        }
    }
    
    private func uiButtonDisabled(_ button: UIButton) {
        DispatchQueue.main.async { [weak weakself = self] in
            if weakself != nil {
                button.isEnabled = false
                button.backgroundColor = weakself!.disabledColor
            }
        }
    }
    
    private func uiButtonEnabled(_ button: UIButton) {
        DispatchQueue.main.async { [weak weakself = self] in
            if weakself != nil {
                button.isEnabled = true
                button.backgroundColor = weakself!.enabledColor
            }
        }
    }
    
    private func textFieldBorderColor(_ textField: UITextField, color: CGColor) {
        textField.layer.borderColor = color
        textField.layer.borderWidth = CGFloat(2.0)
        textField.layer.cornerRadius = CGFloat(6.0)
    }
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBorderColor(textField, color: UIColor.clear.cgColor)
    }
    
}
