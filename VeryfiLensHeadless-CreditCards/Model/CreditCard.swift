//
//  HeadlessCreditCard.swift
//  Lens-Demo
//
//  Created by Alex Levnikov on 4/6/22.
//  Copyright © 2022 Veryfi. All rights reserved.
//

import UIKit

struct CreditCard: Decodable {
    enum CodingKeys: String, CodingKey {
        case number = "card_number"
        case dates = "card_dates"
        case holder = "card_name"
        case cvc = "card_cvc"
        case type = "card_type"
        case identifier = "card_uuid"
    }
    var number: String? = nil
    var holder: String? = nil
    var dates: [String]? = nil
    var cvc: String? = nil
    var type: String? = nil
    var identifier: String? = nil
    
    var dateString: String {
        guard let dates = dates else {
            return ""
        }

        if dates.count == 1 {
            return dates[0]
        } else if dates.count > 1 {
            if dates[0] != "" && dates[1] != "" {
                return dates[0] + "/" + dates[1]
            } else if dates[0] == "" {
                return dates[1]
            } else if dates[1] == "" {
                return dates[0]
            }
        }
        return ""
    }
    
    init() {
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try? container.decode(String.self, forKey: .number)
        holder = try? container.decode(String.self, forKey: .holder)
        cvc = try? container.decode(String.self, forKey: .cvc)
        type = try? container.decode(String.self, forKey: .type)
        identifier = try? container.decode(String.self, forKey: .identifier)
        dates = try? container.decode(Array<String>.self, forKey: .dates)
    }
    
}
