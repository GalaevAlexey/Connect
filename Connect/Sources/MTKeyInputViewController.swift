//
//  MTKeyInputViewController.swift
//  Connect
//
//  Created by Alexey Galaev on 12/20/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit

class MTKeyInputViewController: UIViewController {
    
    weak var delegate: SetupTokenDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    title = "SETUP KEYS".localized
    navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(MTKeyInputViewController.cancel)
        )

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel () {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func handleManualInput(_ sender: Any) {
    }
    
    @IBAction func scanQRCode(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputVC = segue.destination as! MTTokenScannerViewController
        inputVC.delegate = delegate

        if(segue.identifier == Seagues.MANINPUT.rawValue){
            inputVC.title = VCs.manInput
        }
        if(segue.identifier == Seagues.SCANQR.rawValue){
            inputVC.title = VCs.scanQR
        }
    }
}
