//
//  PokemonDetailViewModel.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 03/08/23.
//

import Foundation
import UIKit
import CoreData

class PokemonDetailViewModel {
    var name: String = ""
    var imageURL: String = ""
    var hp: Int = 0
    var cp: Int = 0
    var firstAbility: String = ""
    var secondAbility: String = ""
    var isSwipeBack: Bool = false
    let chance: Int = 50
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isCaught: Bool = false
    
    enum EnumTitleLabel {
        static let release = "Release Pokemon"
        static let loadingCatchMessage = "Catching the Pokemon..."
        static let loadingReleaseMessage = "Releasing the Pokemon..."
        static let successMessage = "This page will be auto-redirected in 4 seconds."
    }
}
