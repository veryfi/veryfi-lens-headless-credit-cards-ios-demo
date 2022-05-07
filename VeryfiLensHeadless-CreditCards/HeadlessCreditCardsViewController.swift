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
    @IBOutlet weak var flipCardImageView: UIImageView!
    
    private var isLensInitialized: Bool = false
    private var isTorchOn = false
    private var shouldCaptureFrames = true
    private var flipExtractionRequired = false
    private var creditCard: CreditCard? = nil
    
    override var shouldAutorotate: Bool {
        return false;
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let credentials = VeryfiLensHeadlessCredentials(clientId: "XXXXXX",
                                                        username: "XXXXXX",
                                                        apiKey: "XXXXXX",
                                                        url: "XXXXXX")
        
        let settings = VeryfiLensCreditCardsSettings()
        settings.marginTop = 70
        settings.marginBottom = 30
        
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
        
        setTorchImage()
        cleanLabels()
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
        cleanUI()
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if cameraView.previewLayer.connection?.isVideoOrientationSupported ?? false {
            cameraView.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(interfaceOrientation:UIApplication.shared.statusBarOrientation) ?? AVCaptureVideoOrientation.portrait
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let dest = segue.destination as? HeadlessCreditCardResultViewControlerViewController {
            dest.creditCard = creditCard
        }
    }
    
    //MARK: IBActions
    @IBAction func unwindToCreditCard(_ unwindSegue: UIStoryboardSegue) {
        cleanUI()
    }
    
    @IBAction func changeTorchMode(_ sender: Any) {
        let captureDeviceClass: AnyClass? = NSClassFromString("AVCaptureDevice")
        if captureDeviceClass != nil {
            let device = AVCaptureDevice.default(for: .video)
            if device?.hasTorch ?? false {
                
                do {
                    try device?.lockForConfiguration()
                } catch {
                }
                
                if isTorchOn {
                    device?.torchMode = .off
                } else {
                    device?.torchMode = .on
                }
                isTorchOn = !isTorchOn
                setTorchImage()
                
                device?.unlockForConfiguration()
            }
        }
    }
    
    //MARK: Private
    private func openSuccessViewController() {
        isTorchOn = false
        setTorchImage()
        cameraView.stopSession()
        VeryfiLensHeadless.shared().reset()
        shouldCaptureFrames = false
        flipExtractionRequired = false
        performSegue(withIdentifier: "creditCardResult", sender: self)
    }
    
    private func cleanLabels() {
        cardCVC.text = ""
        cardDate.text = ""
        cardNumber.text = ""
        cardHolder.text = ""
    }
        
    private func updatePlaceholders(_ creditCard: CreditCard?, shouldOverwriteData: Bool) {
        if let value = creditCard?.holder,
           value != "", (cardHolder.text?.isEmpty ?? true || shouldOverwriteData) {
            cardHolder.isHidden = false
            cardHolder.text = value
        } else {
            cardHolder.isHidden = cardHolder.text?.isEmpty ?? true
        }
        if let value = creditCard?.number,
           value != "", (cardNumber.text?.isEmpty ?? true || shouldOverwriteData)  {
            cardNumber.isHidden = false
            cardNumber.text = value
        } else {
            cardNumber.isHidden = cardNumber.text?.isEmpty ?? true
        }
        if let value = creditCard?.dateString,
           value != "", (cardDate.text?.isEmpty ?? true || shouldOverwriteData)  {
            cardDate.isHidden = false
            cardDate.text = value
        } else {
            cardDate.isHidden = cardDate.text?.isEmpty ?? true
        }
        if let value = creditCard?.cvc,
           value != "", (cardCVC.text?.isEmpty ?? true || shouldOverwriteData)  {
            cardCVC.isHidden = false
            cardCVC.text = value
        } else {
            cardCVC.isHidden = cardCVC.text?.isEmpty ?? true
        }
    }
    
    private func setTorchImage() {
        let imageName = isTorchOn ? "bolt.fill" : "bolt.slash.fill"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: imageName)?.resize(to: CGSize(width: 22, height: 22)), style: .plain, target: self, action: #selector(changeTorchMode))
    }
    
    private func updateModel(_ newCreditCard: CreditCard?) {
        if creditCard == nil {
            creditCard = CreditCard()
        }
        if creditCard?.holder?.isEmpty ?? true {
            creditCard?.holder = newCreditCard?.holder
            VeryfiLensHeadless.shared().settings.detectCardHolderName = creditCard?.holder?.isEmpty ?? true
        }
        if creditCard?.number?.isEmpty ?? true {
            creditCard?.number = newCreditCard?.number
            VeryfiLensHeadless.shared().settings.detectCardNumber = creditCard?.number?.isEmpty ?? true
        }
        if creditCard?.dates?.isEmpty ?? true {
            creditCard?.dates = newCreditCard?.dates
            VeryfiLensHeadless.shared().settings.detectCardDate = creditCard?.dates?.isEmpty ?? true
        }
        if creditCard?.identifier?.isEmpty ?? true {
            creditCard?.identifier = newCreditCard?.identifier
        }
        if creditCard?.type?.isEmpty ?? true {
            creditCard?.type = newCreditCard?.type
        }
        if creditCard?.cvc?.isEmpty ?? true {
            creditCard?.cvc = newCreditCard?.cvc
            VeryfiLensHeadless.shared().settings.detectCardCVC = creditCard?.cvc?.isEmpty ?? true
        }
    }
    
    private func animateFlipImageView() {
        UIView.transition(with: self.flipCardImageView, duration: 1, options: [.transitionFlipFromRight], animations: {
        }) { _ in
            if self.flipExtractionRequired {
                self.animateFlipImageView()
            }
        }
    }
    
    private func requiredCardDataCompleted() -> Bool {
        return !(creditCard?.cvc?.isEmpty ?? true) && !(creditCard?.number?.isEmpty ?? true)  && !(creditCard?.dates?.isEmpty ?? true)  && !(creditCard?.holder?.isEmpty ?? true) && !(creditCard?.dateString.isEmpty ?? true)
    }
    
    
    
    private func cleanUI() {
        flipCardImageView.isHidden = true
        guideLabel.text = "Position your debit or credit card in the frame to scan in"
        cameraView.startSession()
        shouldCaptureFrames = true
        creditCard = nil
        cleanLabels()
        flipExtractionRequired = false
        VeryfiLensHeadless.shared().settings.detectCardNumber = true
        VeryfiLensHeadless.shared().settings.detectCardHolderName = true
        VeryfiLensHeadless.shared().settings.detectCardDate = true
        VeryfiLensHeadless.shared().settings.detectCardCVC = true
        VeryfiLensHeadless.shared().reset()
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
        if isLensInitialized && shouldCaptureFrames{
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
            updatePlaceholders(dataModel, shouldOverwriteData: false)
        }
    }
    
    func veryfiLensSuccess(_ json: [String : Any]) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        if let data = try? JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted),
           let dataModel = try? decoder.decode(CreditCard.self, from: data)  {
            updateModel(dataModel)
            updatePlaceholders(creditCard, shouldOverwriteData: true)
            if flipExtractionRequired || requiredCardDataCompleted() {
                openSuccessViewController()
            } else {
                flipExtractionRequired = true
                shouldCaptureFrames = false
                guideLabel.text = "Flip the card over"
                flipCardImageView.isHidden = false
                animateFlipImageView()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.flipCardImageView.isHidden = true
                    VeryfiLensHeadless.shared().reset()
                    self.shouldCaptureFrames = true
                }
            }
        }
    }
}

extension HeadlessCreditCardsViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        VeryfiLensHeadless.shared().close()
    }
}
