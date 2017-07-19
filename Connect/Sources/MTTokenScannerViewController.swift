//
//  TokenScannerViewController.swift
//  Authenticator
//
//  Created by Alexey Galaev on 11/24/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit
import AVFoundation
import OneTimePassword
import RxCocoa
import RxSwift
import SVProgressHUD
import PopupDialog

enum Actions : String {
    case MAC = "MAC", OTP = "OTP", MACDETAILS = "MACDETAILS"
    static let allValues = [MAC, OTP, MACDETAILS]
}

enum Seagues : String {
    case SETOTP = "setOTP",GETMAC = "getMac", MANINPUT = "manInput", SCANQR = "scanQR"
}

class MTTokenScannerViewController: UIViewController, QRScannerDelegate {
    
    @IBOutlet weak var enterTokenTextfield: UITextField!
    @IBOutlet weak var manualEntryButton: MTButton!
    @IBOutlet weak var keyLabel: UIImageView!
    @IBOutlet weak var lineLabel: UILabel!
    
    weak var delegate: SetupTokenDelegate?
    private let scanner = QRScanner()
    private let videoLayer = AVCaptureVideoPreviewLayer()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(MTTokenScannerViewController.cancel)
        )
        _ = (title == VCs.manInput) ? prepareTextInput() : prepareScanner()
    }
    
    func prepareTextInput(){
        scanner.stop()
        enterTokenTextfield.isHidden = false
        manualEntryButton.isHidden = false
        keyLabel.isHidden = false
        lineLabel.isHidden = false
        
        _ = enterTokenTextfield.rx.controlEvent(.editingDidBegin).bindNext { [unowned self] in
            self.keyLabel.isHighlighted = true
            self.enterTokenTextfield.tintColor = Design.enabledtext
            self.enterTokenTextfield.textColor = Design.enabledtext
            }.addDisposableTo(disposeBag)
    }
    
    func prepareScanner(){
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoLayer)
        let overlayView = ScannerOverlayView(frame: view.bounds)
        view.addSubview(overlayView)
        if (QRScanner.deviceCanScan){
            print("readyToScan")
        }
        scanner.delegate = self
        scanner.start() { captureSession in
            self.videoLayer.session = captureSession
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanner.stop()
    }

    func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: QRScannerDelegate

    func handleDecodedText(text: String) {
        
        scanner.stop()
        cancel()
        
        guard let  url = NSURL(string: text) else {
            handleTransactionInfo(info: text)
            cancel()
            return
        }
        
        if let scheme = url.scheme{
            switch scheme {
            case "macauth": handleMacSecret(secret: text)
            case "otpauth": handleOTPSecret(secret: text)
            default : print("probably mac info")
            }
        }
    }
    
    func handleMacSecret(secret:String) {
        print(secret)
        guard let macsecret = String(secret.TokenSecret) else {
            print("invalidSecret")
            return
        }
        UserProfiles.currentUser.MACSecret = macsecret
        delegate?.handleSecret(action:.MAC)
        updatePersistent()
    }
    
    func handleOTPSecret(secret:String) {
                print(secret)
                guard let otpsecret = String(secret.TokenSecret) else {
                        print("invalidSecret")
                        return
                }
                UserProfiles.currentUser.OTPSecret = otpsecret
                delegate?.handleSecret(action:.OTP)
                updatePersistent()
    }
    
    func handleTransactionInfo(info:String) {
            UserProfiles.currentUser.datailsMAC.value = info
         delegate?.handleSecret(action:.MACDETAILS)
    }
    
    func updatePersistent(){
        let secretData = Data(UserProfiles.currentUser.encryptedKey)
        print(secretData.count)
        keychain.delete(Keys.persistentKey)
        keychain.set(secretData, forKey: Keys.persistentKey,withAccess: .accessibleAfterFirstUnlock)
    }
    
    func handleError(error: Error) {
        print("Error: \(error)")
    }
    
    @IBAction func enterLoginManually(_ sender: Any) {
        guard let probablyToken = enterTokenTextfield.text else {
            handleError()
            return
        }
        if let data = Data(fromHexEncodedString:probablyToken) {
            let secretString = base32Encode(data.arrayOfBytes())
            if (data.arrayOfBytes().count > 16){
                UserProfiles.currentUser.OTPSecret = secretString
            }
            else {
                UserProfiles.currentUser.MACSecret = secretString
            }
        } else {
            handleError()
        }
        cancel()
    }
    
    func handleError() {
        let popup = PopupDialog(title: Messsage.warning, message: Messsage.tokenError, image: nil)
        let buttonOne = DefaultButton(title: "OK") {}
        popup.addButtons([buttonOne])
        self.navigationController?.present(popup, animated: true, completion: nil)
    }
}

