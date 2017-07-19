//
//  MTOTPDetailsViewController.swift
//  Connect
//
//  Created by Alexey Galaev on 12/2/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MTOTPDetailsViewController: UIViewController {

    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var timer: Timer?
    var timerOTP: Timer?
    var timerStart: Date?
    let dateFormatter = DateFormatter()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimers()
        getOTP()
        
        UserProfiles.currentUser.encryptedOTP.asObservable().subscribe { string in
            self.otpLabel.text = string.element
        }.addDisposableTo(disposeBag)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeStyle = .medium
        timeLabel.text = "\(dateFormatter.string(from: Date()))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startTimers() {
        // get current system time
        self.timerStart = Date()
        
        // start the timer
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MTOTPDetailsViewController.update), userInfo: nil, repeats: true)
        self.timerOTP = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(MTOTPDetailsViewController.getOTP), userInfo: nil, repeats: true)
    }
    
    func update() {
        timeLabel.text = "\(dateFormatter.string(from: Date()))"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timerOTP?.invalidate()
    }
    
    func getOTP() {
        guard let encryptedOTP =  CryptoEngine().createOTP(secret: UserProfiles.currentUser.OTPSecret, timeInterval:Counter(date: NSDate()).timeIntervalSince1970) else {
            print("error creadeOTP")
            return
        }
        UserProfiles.currentUser.encryptedOTP.value = encryptedOTP
    }
    
}
