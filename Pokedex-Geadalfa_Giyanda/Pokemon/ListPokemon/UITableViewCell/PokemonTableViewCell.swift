//
//  PokemonTableViewCell.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var combatPointLabel: UILabel!
    @IBOutlet weak var firstAbilityLabel: UILabel!
    @IBOutlet weak var secondAbilityLabel: UILabel!
    @IBOutlet weak var firstAbilityView: UIView!
    @IBOutlet weak var secondAbilityView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    
    func configCell(name: String, imageURL: String, hp: Int, cp: Int, firstAbility: String, secondAbility: String = "") {
        pokemonNameLabel.text = capitalizedName(name: name)
        pokemonImageView.setImage(imageUrl: imageURL, placeholder: UIImage(named: "pokeball"), brokenImage: UIImage(named: "pokeball"))
        setStat(hp: hp, cp: cp)
        setAbility(firstAbility: firstAbility, secondAbility: secondAbility)
        setupCornerShadow()
    }
    
    private func capitalizedName(name: String) -> String {
        let capitalizedWord = name.prefix(1).capitalized + name.dropFirst()
        return capitalizedWord
    }
    
    private func setStat(hp: Int, cp: Int) {
        hpLabel.text = String(hp)
        combatPointLabel.text = String(cp)
    }
    
    private func setAbility(ability: [Ability] = [], firstAbility: String, secondAbility: String) {
        firstAbilityLabel.text = firstAbility.replacingOccurrences(of: "-", with: " ")
        
        guard !secondAbility.isEmpty else {
            secondAbilityView.isHidden = true
            return
        }
        secondAbilityLabel.text = secondAbility.replacingOccurrences(of: "-", with: " ")
    }
    
    private func setupCornerShadow() {
        firstAbilityView.layer.cornerRadius = 6.0
        firstAbilityView.clipsToBounds = true
        secondAbilityView.layer.cornerRadius = 6.0
        secondAbilityView.clipsToBounds = true
        
        cellContentView.layer.cornerRadius = 12.0
        cellContentView.clipsToBounds = true
        cellContentView.setShadow()
    }
}
