//
//  APIServices.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import Alamofire
import RxSwift
import RealmSwift

enum PromoError: Error {
    case invalidResponse
    case decodingError
    case apiError(AFError)
}

class APIServices {
    static let shared = APIServices()
    
    private init() {}
    
    func fetchPokemonList(completion: @escaping ([PokemonModel]?, Error?) -> Void) {
        let apiUrl = BaseID.baseURL
        
        AF.request(apiUrl, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseDecodable(of: PokemonListResponse.self) { response in
                switch response.result {
                case .success(let pokemonListResponse):
                    let pokemonList = pokemonListResponse.results.map { pokemonResult in
                        PokemonModel(id: self.extractPokemonId(from: pokemonResult.url),
                                name: pokemonResult.name,
                                imageURL: "",
                                     url: pokemonResult.url)
                    }
                    completion(pokemonList, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    private func extractPokemonId(from url: String) -> Int {
        guard let idString = url.split(separator: "/").last, let id = Int(idString) else {
            return 0
        }
        return id
    }
    
    func fetchPokemonDetails(pokemon: PokemonModel, completion: @escaping (PokemonModel?, Error?) -> Void) {
        AF.request(pokemon.url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseDecodable(of: PokemonDetailsResponse.self) { response in
                switch response.result {
                case .success(let pokemonDetailsResponse):
                    if let sprites = pokemonDetailsResponse.sprites,
                       let imageURL = sprites.other?.officialArtwork?.frontDefault {
                        let abilities = pokemonDetailsResponse.abilities.map { abilityResponse in
                            return Ability(name: abilityResponse.ability.name,
                                           url: abilityResponse.ability.url)
                        }
                        let stats = pokemonDetailsResponse.stats.map {
                            statResponse in
                            return Stat(baseStat: statResponse.baseStat)
                        }
                        let updatedPokemon = PokemonModel(id: pokemon.id,
                                                          name: pokemon.name,
                                                          imageURL: imageURL,
                                                          url: pokemon.url,
                                                          abilities: abilities, stats: stats)
                        completion(updatedPokemon, nil)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
    
    func fetchPokemonListWithDetails(completion: @escaping ([PokemonModel]?, Error?) -> Void) {
        fetchPokemonList { pokemonList, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let pokemonList = pokemonList else {
                completion(nil, nil)
                return
            }

            var updatedPokemonList: [PokemonModel] = []
            let group = DispatchGroup()

            for pokemon in pokemonList {
                group.enter()
                self.fetchPokemonDetails(pokemon: pokemon) { updatedPokemon, error in
                    if let updatedPokemon = updatedPokemon {
                        updatedPokemonList.append(updatedPokemon)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(updatedPokemonList, nil)
            }
        }
    }
}
