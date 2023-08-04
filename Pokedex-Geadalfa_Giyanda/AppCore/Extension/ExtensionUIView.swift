//
//  ExtensionUIView.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import UIKit

extension UIView {
    func setShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.8)
        self.layer.shadowOpacity = 0.15
        self.layer.shadowRadius = 2.0
        self.layer.masksToBounds = false
    }
}
