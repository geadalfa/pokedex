//
//  ExtensionUIImageView.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import UIKit
import SDWebImage

extension UIImageView {
    func setImage(imageUrl: String, placeholder: UIImage?, brokenImage: UIImage?) {
        if imageUrl == "" {
            self.image = placeholder
        } else if let url = URL(string: imageUrl) {
            self.sd_setImage(with: url,
                             placeholderImage: placeholder) { [weak self] (image, error, _, _) in
                guard let self = self else { return }
                if let image = image {
                    self.image = image
                } else if error != nil {
                    self.image = brokenImage
                } else {
                    self.image = placeholder
                }
            }
        } else {
            self.image = brokenImage
        }
    }
    
    public func loadGif(name: String) {
            DispatchQueue.global().async {
                let image = UIImage.gif(name: name)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
