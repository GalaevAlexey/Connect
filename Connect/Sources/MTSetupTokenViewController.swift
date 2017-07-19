//
//  MTSetupTokenViewController.swift
//  Connect
//
//  Created by Alexey Galaev on 12/2/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PopupDialog
import Navajo
import OneTimePassword

protocol SetupTokenDelegate: class {
    func handleSecret(action: Actions)
    func handleError(error: Error)
}

class MTSetupTokenViewController: UIViewController, SetupTokenDelegate {
    
    @IBOutlet weak var setupOTPButton: UIButton!
    @IBOutlet weak var setupMACButton: UIButton!
    @IBOutlet weak var getMACButton: UIButton!
    @IBOutlet weak var changeOTPButton: MTButton!
    @IBOutlet weak var changeMACButton: MTButton!
    
    @IBOutlet weak var getMACview: UIView!
    @IBOutlet weak var getOTPview: UIView!
    @IBOutlet weak var setOTPview: UIView!
    @IBOutlet weak var setMACview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Connect".localized
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UINavigationController {
            let scannerNavVC = segue.destination as! UINavigationController
            let story = UIStoryboard(name:"MainStoryBoard", bundle: nil)
            if(segue.identifier == Seagues.GETMAC.rawValue){
                let scannerVC = story.instantiateViewController(withIdentifier: "MTTokenScannerViewController") as! MTTokenScannerViewController
                scannerVC.delegate = self
                scannerNavVC.setViewControllers([scannerVC], animated:true)
            } else {
                let inputVC = story.instantiateViewController(withIdentifier: "MTKeyInputViewController") as! MTKeyInputViewController
                inputVC.delegate = self
                scannerNavVC.setViewControllers([inputVC], animated:true)
            }
        }
    }
    
    func configureView() {
        !UserProfiles.currentUser.OTPSecret.isEmpty ? handleOTP() : print("Need set OTP")
        !UserProfiles.currentUser.MACSecret.isEmpty ? handleMAC() : print("Need set Mac")
    }
    
    func handleSecret(action:Actions) {
        switch action {
        case .OTP : handleOTP()
        case .MAC : handleMAC()
        case .MACDETAILS : handleDetails()
        }
    }
    
    func handleOTP() {
        view.sendSubview(toBack: setOTPview)
        view.bringSubview(toFront: getOTPview)
        view.bringSubview(toFront: changeOTPButton)
    }
    
    func handleMAC() {
        view.sendSubview(toBack: setMACview)
        view.bringSubview(toFront: getMACview)
        view.bringSubview(toFront: changeMACButton)
    }
    
    func handleDetails() {
        var isBusy = false
        let storedMACSecret = UserProfiles.currentUser.MACSecret
        let storedMACDetails = UserProfiles.currentUser.datailsMAC.value
        if(!isBusy){
            CryptoEngine().createMac(mackey: storedMACSecret, msg: storedMACDetails) {result, message in
                isBusy = true
                if(result){
                    UserProfiles.currentUser.encryptedMAC.value = message
                    let storyb = UIStoryboard(name:"MainStoryBoard", bundle: nil)
                    if  let  macDetailsVC = storyb.instantiateViewController(withIdentifier:"macdetailsVC") as? MTMACDetailsViewController {
                        self.navigationController?.show(macDetailsVC, sender: nil)
                        isBusy = !result
                    }
                } else {
                    self.handleError(error: message as! Error)
                }
            }
        }
    }

    func handleError(error: Error) {
        print(error)
    }
}
