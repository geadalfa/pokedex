//
//  PokemonModels.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import Foundation
import RealmSwift

class PokemonModel: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var imageURL: String
    @Persisted var url: String
    @Persisted var abilities: List<Ability>
    @Persisted var stats: List<Stat>
    
    convenience init(id: Int, name: String, imageURL: String, url: String, abilities: [Ability] = [], stats: [Stat] = []) {
        self.init()
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.url = url
        self.abilities.append(objectsIn: abilities)
        self.stats.append(objectsIn: stats)
    }
}

class Ability: Object {
    @Persisted var name: String
    @Persisted var url: String

    convenience init(name: String, url: String) {
        self.init()
        self.name = name
        self.url = url
    }
}

class Stat: Object {
    @Persisted var baseStat: Int
    
    convenience init(baseStat: Int) {
        self.init()
        self.baseStat = baseStat
    }
}

struct PokemonListResponse: Decodable {
    let results: [PokemonResult]
}

struct PokemonResult: Decodable {
    let name: String
    let url: String
}

struct PokemonDetailsResponse: Decodable {
    let abilities: [PokemonAbility]
    let sprites: PokemonSprites?
    let stats: [PokemonStats]
}

struct PokemonAbility: Decodable {
    let ability: AbilityDetails
}

struct AbilityDetails: Decodable {
    let name: String
    let url: String
}

struct PokemonStats: Decodable {
    let baseStat: Int
    
    private enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
    }
}

struct PokemonSprites: Decodable {
    let frontDefault: String?
    let other: Other?
    
    private enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case other
    }
}

struct Other: Decodable {
    let officialArtwork: OfficialArtwork?
    
    private enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Decodable {
    let frontDefault: String?

        private enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
}
