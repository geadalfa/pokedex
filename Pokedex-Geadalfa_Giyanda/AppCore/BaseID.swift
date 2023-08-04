//
//  BaseID.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import Foundation

struct BaseID {
    static var randomOffset: String {
        return "\(Int.random(in: 0...1000))"
    }
    
    static var baseURL: String {
        return "https://pokeapi.co/api/v2/pokemon?offset=\(randomOffset)&limit=20"
    }
}
