
//
//  ViewController.swift
//  Connect
//
//  Created by Alexey Galaev on 11/9/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PopupDialog
import Navajo
import OneTimePassword

typealias ValidationResult = (valid: Bool, message: String?)
typealias CompletionMac = (_ valid:Bool, _ result:String) -> ();

let disposeBag = DisposeBag()
class MTSinginViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var oldPassLineLabel: UILabel!
    @IBOutlet weak var oldPasswordKeyLabel: UIImageView!
    @IBOutlet weak var oldPasswordLabel: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordKeyLabel: UIImageView!
    @IBOutlet weak var passwordLineLabel: UILabel!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var confirmKeyLabel: UIImageView!
    @IBOutlet weak var confirmLineLabel: UILabel!
    @IBOutlet weak var generateButton: MTButton!
    @IBOutlet weak var enterButton: MTButton!
    
    @IBOutlet weak var secureEntrySwitch: UISwitch!
    @IBOutlet weak var secureLabel: UILabel!
    
    let engine = CryptoEngine()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(title == "Reset password".localized){
            oldPassLineLabel.isHidden = false
            oldPasswordKeyLabel.isHidden = false
            oldPasswordLabel.isHidden = false
            passwordField.isEnabled = false
            confirmPasswordField.isEnabled = false
        
            _ = oldPasswordLabel.rx.controlEvent(.editingDidBegin).bindNext { [unowned self] in
        
                self.oldPassLineLabel.backgroundColor = Design.orange
                self.oldPasswordLabel.tintColor = Design.enabledtext
                self.oldPasswordLabel.textColor = Design.enabledtext
            
                }.addDisposableTo(disposeBag)
            
            _ = oldPasswordLabel.rx.controlEvent(.editingDidEnd).bindNext { [unowned self] in
                
                self.oldPasswordKeyLabel.isHighlighted = false;
                self.oldPassLineLabel.backgroundColor = Design.disabled
                self.oldPasswordLabel.tintColor = Design.disabledtext
                self.oldPasswordLabel.textColor = Design.disabledtext
                
                let isPassValid = self.validateOldPassword(oldPassword:self.oldPasswordLabel.text!)
                self.oldPasswordLabel.isEnabled = !isPassValid
                self.oldPasswordKeyLabel.isHighlighted = isPassValid;
                self.passwordField.isEnabled = isPassValid
                self.confirmPasswordField.isEnabled = isPassValid
                if(!isPassValid) {
                    let popup = PopupDialog(title: Messsage.title, message: Messsage.loginError, image: nil)
                    let buttonOne = DefaultButton(title: "OK".localized) {}
                    popup.addButtons([buttonOne])
                self.navigationController?.present(popup, animated: true, completion: nil)
                }
                }.addDisposableTo(disposeBag)
        }
        
        secureEntrySwitch.setOn(false, animated: false)
        oldPasswordLabel.isSecureTextEntry = false
        passwordField.isSecureTextEntry = false
        confirmPasswordField.isSecureTextEntry = false
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "i"),
                                                                  style: .plain ,
                                                                  target: self, action: #selector(MTSinginViewController.infoClicked))

        let passwordValid = passwordField.rx.text.orEmpty
            .map { password in
                return self.validatePassword(password: password)
        }.shareReplay(1)
        
        let repeatPassword = Observable.combineLatest(passwordField.rx.text.orEmpty, confirmPasswordField.rx.text.orEmpty){ password, confirmPassword in
            return self.validateRepeatPassword(password: password, repeatedPassword: confirmPassword)
        }.shareReplay(1)
        
        let singupEnabled =  Observable.combineLatest(passwordValid, repeatPassword){
            $0.valid && $1.valid }.shareReplay(1)
        
        singupEnabled.bindTo(enterButton.rx.isEnabled).addDisposableTo(disposeBag)
        
        _ = passwordField.rx.controlEvent(.editingDidBegin).bindNext { [unowned self] in
            self.passwordLineLabel.backgroundColor = Design.orange
            self.passwordField.tintColor = Design.enabledtext
            self.passwordField.textColor = Design.enabledtext
        }.addDisposableTo(disposeBag)
        
        _ = passwordField.rx.controlEvent(.editingDidEnd).bindNext { [unowned self] in
            self.passwordLineLabel.backgroundColor = Design.disabled
            self.passwordField.tintColor = Design.disabledtext
            self.passwordField.textColor = Design.disabledtext
            self.validatePasswords()
        }.addDisposableTo(disposeBag)
        
        _ = confirmPasswordField.rx.controlEvent(.editingDidBegin).bindNext { [unowned self] in
            self.confirmLineLabel.backgroundColor = Design.orange
            self.confirmPasswordField.tintColor = Design.enabledtext
            self.confirmPasswordField.textColor = Design.enabledtext
        }.addDisposableTo(disposeBag)
        
        _ = confirmPasswordField.rx.controlEvent(.editingDidEnd).bindNext { [unowned self] in
            self.confirmLineLabel.backgroundColor = Design.disabled
            self.confirmPasswordField.tintColor = Design.disabledtext
            self.confirmPasswordField.textColor = Design.disabledtext
            self.validatePasswords()
        }.addDisposableTo(disposeBag)
        
        enterButton.rx.tap
            .subscribe(onNext: { [unowned self] in
             UserProfiles.currentUser.password = self.engine.generatePKCS5(pass: self.passwordField.text!)
                print(UserProfiles.currentUser.password)
                keychain.delete(Keys.persistentKey)
               
                let story = UIStoryboard(name:"MainStoryBoard", bundle: nil)
                
                let  setupTokenVC = story.instantiateViewController(withIdentifier: "SetuptokenVC") as! MTSetupTokenViewController
         
                if let navController = self.navigationController {
                    navController.setViewControllers([setupTokenVC], animated: true)
                }
                print(UserProfiles.currentUser.encryptedKey)
                keychain.set(Data(UserProfiles.currentUser.encryptedKey), forKey: Keys.persistentKey)
                UserDefaults.standard.set(true, forKey:Keys.firstRunKey)
            })
            .addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func generatePassword(_ sender: Any) {
        let generator = PasswordGenerator()
        let generatedPassword = Variable(generator.generate())
        _ = passwordField.rx.textInput <-> generatedPassword
        passwordField.text = generatedPassword.value
        validatePasswords()
    }

    
    @IBAction func showPassword(_ sender: UISwitch) {
        let state = sender.isOn ? true : false
        passwordField.isSecureTextEntry = state
        confirmPasswordField.isSecureTextEntry = state
        oldPasswordLabel.isSecureTextEntry = state
        secureLabel.text = state ? "Show password".localized : "Hide password".localized
    }

    func infoClicked() {
    
        let popup = PopupDialog(title: Messsage.title, message: Messsage.passwordNote, image: nil)
        
        let buttonOne = DefaultButton(title: "OK".localized) {}
        popup.addButtons([buttonOne])
        self.navigationController?.present(popup, animated: true, completion: nil)
    }
    
    func validatePassword(password:String) -> ValidationResult {
        
        let lengthRule = NJOLengthRule(min: 10, max: 20)
        let lowercaseRule = NJORequiredCharacterRule(preset: .lowercaseCharacter)
        let uppercaseRule = NJORequiredCharacterRule(preset: .uppercaseCharacter)
        let decimalRule = NJORequiredCharacterRule(preset: .decimalDigitCharacter)
        let symbolRule  = NJORequiredCharacterRule(preset: .symbolCharacter)
        
        let validator = NJOPasswordValidator(rules: [lengthRule, uppercaseRule, lowercaseRule, decimalRule, symbolRule])
        
        if let failingRules = validator.validate(password) {
            var errorMessages: [String] = []
            
            failingRules.forEach { rule in
                errorMessages.append(rule.localizedErrorDescription.localized)
            }
            
            let errorMessage = errorMessages.joined(separator: "\n")
            return (false, errorMessage)
        } else {
            return (true, "")
        }
    }
    
    func validateRepeatPassword(password:String,repeatedPassword:String) -> ValidationResult {
        if(password == repeatedPassword) {
            return  (true,"")
        } else{
            return (false, "")
        }
    }
    
    func validatePasswords(){
        let commonValidation = (validatePassword(password: passwordField.text!),validateRepeatPassword(password: passwordField.text!, repeatedPassword: confirmPasswordField.text!))
            self.passwordKeyLabel.isHighlighted = commonValidation.0.valid
            self.confirmKeyLabel.isHighlighted = commonValidation.1.valid
            self.enterButton.isEnabled = true
        if(!commonValidation.0.valid || !commonValidation.1.valid){
            self.enterButton.isEnabled = false
            let message = (commonValidation.1.valid || !(commonValidation.0.message?.isEmpty)!) ? commonValidation.0.message : "Passwords dont match".localized
                        let popup = PopupDialog(title: Messsage.title, message: message, image: nil)
                        let buttonOne = DefaultButton(title: "OK") {}
                        popup.addButtons([buttonOne])
                        self.navigationController?.present(popup, animated: true, completion: nil)
        }
    }
    
    func validateOldPassword(oldPassword:String) -> Bool{
        let result = CryptoEngine().loginWithPassword(pass: oldPassword)
        return result
    }
}

