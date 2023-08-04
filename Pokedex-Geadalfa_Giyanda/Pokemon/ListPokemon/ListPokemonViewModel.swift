//
//  ListPokemonViewModel.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import Foundation
import RxSwift

class ListPokemonViewModel {
    private let disposeBag = DisposeBag()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let pokemonDataSubject = PublishSubject<[PokemonModel]>()
    var pokemonDataObservable: Observable<[PokemonModel]> {
        return pokemonDataSubject.asObservable()
    }
    
    var isFinishRequest: Bool = false
    
    func fetchData() {
        APIServices.shared.fetchPokemonListWithDetails { [weak self] updatedPokemonList, error in
            guard let self = self else { return }
            
            if let error = error {
                print("\(Constants.ERROR_TEXT_FAILED): \(error)")
                self.isFinishRequest = true
                return
            }
            
            if let updatedPokemonList = updatedPokemonList {
                self.pokemonDataSubject.onNext(updatedPokemonList)
                self.isFinishRequest = true
            }
        }
    }
}
    
// Enum
extension ListPokemonViewModel {
    enum EnumPokemonTableViewCell: String {
        case pokemonTableViewCell = "PokemonTableViewCell"
        static let value: [EnumPokemonTableViewCell] = [.pokemonTableViewCell]
    }
}
