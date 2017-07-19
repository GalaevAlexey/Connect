//
//  MTMACDetailsViewController.swift
//  Connect
//
//  Created by Alexey Galaev on 12/8/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit

class MTMACDetailsViewController: UIViewController {

    @IBOutlet weak var macDetailsLabel: UILabel!
    @IBOutlet weak var macTokenLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UserProfiles.currentUser.encryptedMAC.asObservable().subscribe { string in
            self.macTokenLabel.text = string.element
            }.addDisposableTo(disposeBag)
        UserProfiles.currentUser.datailsMAC.asObservable().subscribe { string in
            let formatedDetails = " " + (string.element?.replacingOccurrences(of:",", with:"\n"))!
            self.macDetailsLabel.text = formatedDetails
            }.addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
