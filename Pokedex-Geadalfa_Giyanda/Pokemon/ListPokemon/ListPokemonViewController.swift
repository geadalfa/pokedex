//
//  ListPokemonViewController.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

class ListPokemonViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myPokemonTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var segmentedButton: UISegmentedControl!
    
    let viewModel = ListPokemonViewModel()
    let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        updateFetchCoreData()
        tableView.reloadData()
        myPokemonTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
    }
    
    private func setupSubViews() {
        setupLoadingImage()
        setupTableView()
        myPokemonSetupTableView()
        headerView.setShadow()
        setupSegmentControl()
    }
    
    private func setupSegmentControl() {
        segmentedButton.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    @objc private func segmentedControlValueChanged() {
        if segmentedButton.selectedSegmentIndex == 0 {
            tableView.isHidden = false
            myPokemonTableView.isHidden = true
        } else {
            tableView.isHidden = true
            myPokemonTableView.isHidden = false
            updateFetchCoreData()
        }
    }
    
    private func setupTableView() {
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.layoutIfNeeded()
        tableView.delegate = self
        
        myPokemonTableView.isHidden = true
        dataSource()
    }
    
    private func myPokemonSetupTableView() {
        myPokemonTableView.tableHeaderView = UIView(frame: .zero)
        myPokemonTableView.tableFooterView = UIView(frame: .zero)
        myPokemonTableView.sectionHeaderHeight = 0
        myPokemonTableView.sectionFooterHeight = 0
        myPokemonTableView.estimatedRowHeight = 100.0
        myPokemonTableView.rowHeight = UITableView.automaticDimension
        myPokemonTableView.separatorStyle = .none
        myPokemonTableView.showsVerticalScrollIndicator = false
        myPokemonTableView.layoutIfNeeded()
        myPokemonTableView.delegate = self
        
        myPokemonDataSource()
    }

    private func dataSource() {
        viewModel.fetchData()
        
        for cell in ListPokemonViewModel.EnumPokemonTableViewCell.value {
            tableView.register(UINib(nibName: cell.rawValue, bundle: nil), forCellReuseIdentifier: cell.rawValue)
        }
        
        viewModel.pokemonDataObservable
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: ListPokemonViewModel.EnumPokemonTableViewCell.pokemonTableViewCell.rawValue, cellType: PokemonTableViewCell.self)) { [weak self] index, pokemon, cell in
                guard let self = self else { return }
                self.setupLoadingImage()
                let pokemonAbilities = pokemon.abilities
                let secondAbilities = pokemonAbilities.count > 1 ? pokemonAbilities[1].name : ""
                cell.configCell(name: pokemon.name,
                                imageURL: pokemon.imageURL,
                                hp: pokemon.stats[0].baseStat,
                                cp: pokemon.stats[1].baseStat,
                                firstAbility: pokemonAbilities[0].name,
                                secondAbility: secondAbilities)
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(PokemonModel.self)
            .subscribe(onNext: { [weak self] pokemon in
                guard let self = self else { return }
                let pokemonAbilities = pokemon.abilities
                let secondAbilities = pokemonAbilities.count > 1 ? pokemonAbilities[1].name : ""
                let detailViewController = PokemonDetailViewController(name: pokemon.name, imageUrl: pokemon.imageURL, hp: pokemon.stats[0].baseStat, cp: pokemon.stats[1].baseStat, firstAbility: pokemonAbilities[0].name, secondAbility: secondAbilities)
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func myPokemonDataSource() {
        for cell in ListPokemonViewModel.EnumPokemonTableViewCell.value {
            myPokemonTableView.register(UINib(nibName: cell.rawValue, bundle: nil), forCellReuseIdentifier: cell.rawValue)
        }
        
        callCoreDataSource()
        
        myPokemonTableView.rx.modelSelected(PokemonData.self)
            .subscribe(onNext: { [weak self] pokemon in
                guard let self = self else { return }
                let pokemonAbilities = [pokemon.firstAbility, pokemon.secondAbility].compactMap { $0 }
                let detailViewController = PokemonDetailViewController(name: String(pokemon.name ?? ""),
                                                                       imageUrl: pokemon.imageURL ?? "",
                                                                       hp: Int(pokemon.hp),
                                                                       cp: Int(pokemon.cp),
                                                                       firstAbility: String(pokemonAbilities.first ?? ""),
                                                                       secondAbility: pokemonAbilities.count > 1 ? pokemonAbilities[1] : "", isCaught: true)
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func callCoreDataSource() {
        let pokemonData = fetchDataFromCoreData()
        Observable.just(pokemonData)
            .bind(to: myPokemonTableView.rx.items(cellIdentifier: ListPokemonViewModel.EnumPokemonTableViewCell.pokemonTableViewCell.rawValue, cellType: PokemonTableViewCell.self)) { [weak self] index, pokemon, cell in
                guard let self = self else { return }
                let pokemonAbilities = [pokemon.firstAbility, pokemon.secondAbility].compactMap { $0 }
                cell.configCell(name: pokemon.name ?? "",
                                imageURL: pokemon.imageURL ?? "",
                                hp: Int(pokemon.hp),
                                cp: Int(pokemon.cp),
                                firstAbility: pokemonAbilities.first ?? "",
                                secondAbility: pokemonAbilities.count > 1 ? pokemonAbilities[1] : "")
            }.disposed(by: disposeBag)
    }
    
    private func updateFetchCoreData() {
        myPokemonTableView.delegate = nil
        myPokemonTableView.dataSource = nil
        callCoreDataSource()
    }
    
    private func setupLoadingImage() {
        loadingImageView.loadGif(name: "loading")
        if self.viewModel.isFinishRequest {
            self.loadingView.isHidden = true
        }
    }
}

// MARK: - Core Data
extension ListPokemonViewController {
    private func fetchDataFromCoreData() -> [PokemonData] {
        let context: NSManagedObjectContext = viewModel.appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()

        do {
            let pokemonData = try context.fetch(fetchRequest)
            self.viewModel.isFinishRequest = true
            return pokemonData
        } catch {
            print("Error fetching data from Core Data: \(error)")
            return []
        }
    }
}
