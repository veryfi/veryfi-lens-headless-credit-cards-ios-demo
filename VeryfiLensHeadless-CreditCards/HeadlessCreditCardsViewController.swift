//
//  UIViewController.swift
//  Veryfi-Lens
//
//  Created by Alex Levnikov on 28.03.22.
//  Copyright © 2022 Veryfi. All rights reserved.
//

import UIKit
import VeryfiLensHeadless
import AVFoundation

class HeadlessCreditCardsViewController: UIViewController {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardDate: UILabel!
    @IBOutlet weak var cardCVC: UILabel!
    @IBOutlet weak var cardHolder: UILabel!
    @IBOutlet weak var guide: UILabel!
    @IBOutlet weak var guideLabel: UILabel!
    private var isLensInitialized: Bool = false
    
    private enum State {
        case front
        case back
        case result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let credentials = VeryfiLensHeadlessCredentials(clientId: "XXXXXX",
                                                        username: "XXXXXX",
                                                        apiKey: "XXXXXX",
                                                        url: "XXXXXX")
        
        let settings = VeryfiLensCreditCardsSettings()
        settings.isGPUEnabled = true
        
        VeryfiLensHeadless.shared().delegate = self
        
        VeryfiLensHeadless.shared().configure(with: credentials,
                                              settings: settings) {[weak self] success in
            self?.isLensInitialized = success
            if !success {
                DispatchQueue.main.async { [weak self] in
                    let alertController = UIAlertController(title: "Wrong Credentials", message: "Please make sure correct credentials are used", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        cameraView.configure()
        cameraView.delegate = self
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = 4
        
        presentationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraView.stopSession()
        creditCard = nil
        VeryfiLensHeadless.shared().reset()
        state = .front
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if cameraView.previewLayer.connection?.isVideoOrientationSupported ?? false {
            cameraView.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(interfaceOrientation:UIApplication.shared.statusBarOrientation) ?? AVCaptureVideoOrientation.portrait
        }
    }
    
    override var shouldAutorotate: Bool {
        return false;
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let dest = segue.destination as? HeadlessCreditCardResultViewControlerViewController {
            dest.creditCard = creditCard
        }
    }
    
    private var state: State = .front {
        didSet {
            VeryfiLensHeadless.shared().reset()
            switch state {
            case .front:
                guideLabel.text = "Position your debit or credit card in the frame to scan in"
            case .back:
                guideLabel.text = "Flip the card over"
            case .result:
                cameraView.stopSession()
                VeryfiLensHeadless.shared().reset()
                self.isLensInitialized = false
                performSegue(withIdentifier: "creditCardResult", sender: self)
            }
        }
    }
    
    var creditCard: CreditCard? = nil {
        didSet {
            if let value = creditCard?.holder,
               value != "" {
                cardHolder.isHidden = false
                cardHolder.text = value
            } else {
                cardHolder.isHidden = true
            }
            if let value = creditCard?.number,
               value != ""  {
                cardNumber.isHidden = false
                cardNumber.text = value
            } else {
                cardNumber.isHidden = true
            }
            if let value = creditCard?.dateString,
               value != ""  {
                cardDate.isHidden = false
                cardDate.text = value
            } else {
                cardDate.isHidden = true
            }
            if let value = creditCard?.cvc,
               value != ""  {
                cardCVC.isHidden = false
                cardCVC.text = value
            } else {
                cardCVC.isHidden = true
            }
        }
    }
    
    private func nextState() {
        switch state {
        case .front:
            state = .back
        case .back:
            if let cvv = creditCard?.cvc,
               cvv != "" {
                state = .result
            } else {
                VeryfiLensHeadless.shared().reset()
            }
        case .result:
            state = .front
        }
    }
    
    private func merge(_ creditCard1: CreditCard?, creditCard2: CreditCard?, shouldFixExistingFields: Bool) -> CreditCard? {
        guard let creditCard1 = creditCard1 else {
            if let creditCard2 = creditCard2 {
                return creditCard2
            }
            return nil
        }
        guard let creditCard2 = creditCard2 else {
            return creditCard1
        }
        if shouldFixExistingFields {
            var mergedCreditCard = CreditCard()
            mergedCreditCard.holder = (creditCard1.holder == nil ||  creditCard1.holder == "") ? creditCard2.holder ?? "" : creditCard1.holder
            mergedCreditCard.number = (creditCard1.number == nil ||  creditCard1.number == "") ? creditCard2.number ?? "" : creditCard1.number
            mergedCreditCard.dates = (creditCard1.dateString == "") ? creditCard2.dates ?? [] : creditCard1.dates
            mergedCreditCard.identifier = (creditCard1.identifier == nil ||  creditCard1.identifier == "")  ? creditCard2.identifier ?? "" : creditCard1.identifier
            mergedCreditCard.type = (creditCard1.type == nil ||  creditCard1.type == "") ? creditCard2.type ?? "" : creditCard1.type
            mergedCreditCard.cvc = (creditCard1.cvc == nil ||  creditCard1.cvc == "") ? creditCard2.cvc ?? "" : creditCard1.cvc
            return mergedCreditCard
        } else {
            var mergedCreditCard = CreditCard()
            mergedCreditCard.holder = (creditCard2.holder != nil && creditCard2.holder != "") ? creditCard2.holder! : creditCard1.holder
            mergedCreditCard.number = (creditCard2.number != nil && creditCard2.number != "") ? creditCard2.number! : creditCard1.number
            mergedCreditCard.dates = (creditCard2.dateString != "") ? creditCard2.dates : creditCard1.dates
            mergedCreditCard.identifier = (creditCard2.identifier != nil && creditCard2.identifier != "") ? creditCard2.identifier! : creditCard1.identifier
            mergedCreditCard.type = (creditCard2.type != nil && creditCard2.type != "") ? creditCard2.type! : creditCard1.type
            mergedCreditCard.cvc = (creditCard2.cvc != nil && creditCard2.cvc != "") ? creditCard2.cvc! : creditCard1.cvc
            return mergedCreditCard
        }
    }
    
    @IBAction func unwindToCreditCard(_ unwindSegue: UIStoryboardSegue) {
        cameraView.startSession()
        self.isLensInitialized = true
        creditCard = nil
        VeryfiLensHeadless.shared().reset()
        state = .front
    }
}

extension HeadlessCreditCardsViewController: CameraViewDelegate {
    func cameraView(_ cameraView: CameraView, didFail error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .cancel,
                                                handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func cameraView(_ cameraView: CameraView, didCapture frame: CMSampleBuffer) {
        if isLensInitialized {
            VeryfiLensHeadless.shared().process(buffer: frame)
        }
    }
}


extension HeadlessCreditCardsViewController: VeryfiLensHeadlessDelegate {
    func veryfiLensClose(_ json: [String : Any]) {
        
    }
    
    func veryfiLensError(_ json: [String : Any]) {
        let alertController = UIAlertController(title: "Error", message: String(describing: json), preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .cancel,
                                                handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func veryfiLensUpdate(_ json: [String : Any]) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        if let data = try? JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted),
           let dataModel = try? decoder.decode(CreditCard.self, from: data)  {
            if state != .back {
                creditCard = merge(creditCard, creditCard2: dataModel, shouldFixExistingFields: false)
            }
        }
    }
    
    func veryfiLensSuccess(_ json: [String : Any]) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        if let data = try? JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted),
           let dataModel = try? decoder.decode(CreditCard.self, from: data)  {
            creditCard = merge(creditCard, creditCard2: dataModel, shouldFixExistingFields: true)
            nextState()
        }
    }
}

extension HeadlessCreditCardsViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        VeryfiLensHeadless.shared().close()
    }
}
