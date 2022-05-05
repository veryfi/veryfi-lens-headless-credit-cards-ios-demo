//
//  UIImage+Extensions.swift
//  VeryfiLensHeadless-CreditCards
//
//  Created by Sebastian Giraldo on 5/05/22.
//

import UIKit

extension UIImage {
    @objc func resize(to newSize: CGSize) -> UIImage? {
        let scale = max(newSize.width/self.size.width, newSize.height/self.size.height)
        let width = self.size.width * scale
        let height = self.size.height * scale
        let rect = CGRect(x: (newSize.width - width) / 2, y: (newSize.height - height) / 2, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
