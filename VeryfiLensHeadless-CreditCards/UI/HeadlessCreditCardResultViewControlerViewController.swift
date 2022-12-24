//
//  HeadlessCreditCardResultViewControlerViewController.swift
//  Lens-Demo
//
//  Created by Alex Levnikov on 4/4/22.
//  Copyright © 2022 Veryfi. All rights reserved.
//

import UIKit
import VeryfiLensHeadlessCreditCards

class HeadlessCreditCardResultViewControlerViewController: UIViewController {
    enum FieldType: String {
        case name = "Name"
        case number = "Card Number"
        case date = "Expiry Date"
        case cvc = "Security Code"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func reset(_ sender: Any) {
        VeryfiLensHeadless.shared().reset()
        performSegue(withIdentifier: "unwindToCreditCard", sender: self)
    }
    var creditCard: CreditCard? = nil {
        didSet {
            guard let creditCard = creditCard else {
                return
            }
            fields = fields(from: creditCard)
        }
    }
    
    private var fields: [(FieldType, String)] = [] {
        didSet {
            if tableView != nil {
                tableView.reloadData()
            }
            
        }
    }
    
    func fields(from creditCard: CreditCard) -> [(FieldType, String)] {
        var fieldsArray: [(FieldType, String)] = []
        if let value = creditCard.holder {
            fieldsArray.append((FieldType.name, value))
        } else {
            fieldsArray.append((FieldType.name, ""))
        }
        if let value = creditCard.number {
            fieldsArray.append((FieldType.number, value))
        } else {
            fieldsArray.append((FieldType.number, ""))
        }
        fieldsArray.append((FieldType.date, creditCard.dateString))
        if let value = creditCard.cvc {
            fieldsArray.append((FieldType.cvc, value))
        } else {
            fieldsArray.append((FieldType.cvc, ""))
        }
        return fieldsArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        presentationController?.delegate = self
        // Do any additional setup after loading the view.
    }
}

extension HeadlessCreditCardResultViewControlerViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        VeryfiLensHeadless.shared().close()
    }
}

extension HeadlessCreditCardResultViewControlerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath) as? CreditCardDetailsCell {
            cell.title = fields[indexPath.row].0.rawValue
            cell.text = " \(fields[indexPath.row].1) "
            return cell
        }
        return UITableViewCell()
    }
}
