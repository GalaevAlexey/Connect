//
//  LoginViewController.swift
//  Connect
//
//  Created by Alexey Galaev on 11/15/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit
import PopupDialog
import RxCocoa
import RxSwift

class MTLoginViewController: UIViewController {

    @IBOutlet weak var keyLabel: UIImageView!
    @IBOutlet weak var lineLabel: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
   
    let storyb = UIStoryboard(name:"MainStoryBoard", bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login".localized
      
        _ = passwordTextField.rx.controlEvent(.editingDidBegin).bindNext { [unowned self] in
            self.keyLabel.isHighlighted = true
            self.passwordTextField.tintColor = Design.enabledtext
            self.passwordTextField.textColor = Design.enabledtext
            }.addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        let isLoginSucsessfull = CryptoEngine().loginWithPassword(pass: passwordTextField.text ?? "")
        if(isLoginSucsessfull){
            
            let  setupTokenVC = storyb.instantiateViewController(withIdentifier: "SetuptokenVC") as! MTSetupTokenViewController
            
            if let navController = self.navigationController {
                navController.setViewControllers([setupTokenVC], animated: true)
            } } else {
            let popup = PopupDialog(title: Messsage.warning, message: Messsage.loginError, image: nil)
            let buttonOne = DefaultButton(title: "OK") {}
            popup.addButtons([buttonOne])
            self.navigationController?.present(popup, animated: true, completion: nil)
        }
    }
    
    @IBAction func resetpass(_ sender: Any) {
        if let navController = self.navigationController {
            let resetPassController = storyb.instantiateViewController(withIdentifier: "singinViewControler") as! MTSinginViewController
                resetPassController.title = "Reset password".localized
            navController.show(resetPassController, sender:nil)
        }
    }
}
