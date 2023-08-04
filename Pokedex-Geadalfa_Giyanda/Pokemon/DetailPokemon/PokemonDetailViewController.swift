//
//  PokemonDetailViewController.swift
//  Pokedex-Geadalfa_Giyanda
//
//  Created by Geadalfa Giyanda on 02/08/23.
//

import UIKit
import RxSwift
import CoreData

class PokemonDetailViewController: UIViewController {
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var combatPointLabel: UILabel!
    @IBOutlet weak var firstAbilityLabel: UILabel!
    @IBOutlet weak var secondAbilityLabel: UILabel!
    @IBOutlet weak var firstAbilityView: UIView!
    @IBOutlet weak var secondAbilityView: UIView!
    @IBOutlet weak var detailContentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var catchButton: UIButton!
    @IBOutlet weak var loadingCatchImageView: UIImageView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    private let viewModel = PokemonDetailViewModel()
    var disposeBag = DisposeBag()
    
    convenience init(name: String, imageUrl: String, hp: Int, cp: Int, firstAbility: String, secondAbility: String, isCaught: Bool = false) {
        self.init()
        viewModel.name = name
        viewModel.imageURL = imageUrl
        viewModel.hp = hp
        viewModel.cp = cp
        viewModel.firstAbility = firstAbility
        viewModel.secondAbility = secondAbility
        viewModel.isCaught = isCaught
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addSwipeBack()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeSwipeBack()
    }
}

// MARK: - Setup
extension PokemonDetailViewController {
    private func setupSubViews() {
        setupView()
        setupBackButton()
        setupCatchButton()
        setupTryAgainButton()
    }
    
    private func setupView() {
        pokemonNameLabel.text = capitalizedName(name: viewModel.name)
        pokemonImageView.setImage(imageUrl: viewModel.imageURL, placeholder: UIImage(named: "pokeball"), brokenImage: UIImage(named: "pokeball"))
        setStat()
        setAbility()
        setupCornerShadow()
        resultView.isHidden = true
    }
    
    private func capitalizedName(name: String) -> String {
        let capitalizedWord = name.prefix(1).capitalized + name.dropFirst()
        return capitalizedWord
    }
    
    private func setStat() {
        hpLabel.text = String(viewModel.hp)
        combatPointLabel.text = String(viewModel.cp)
    }
    
    private func setAbility() {
        firstAbilityLabel.text = viewModel.firstAbility.replacingOccurrences(of: "-", with: " ")
        guard !viewModel.secondAbility.isEmpty
        else {
            secondAbilityView.isHidden = true
            return
        }
        secondAbilityLabel.text = viewModel.secondAbility.replacingOccurrences(of: "-", with: " ")
    }
    
    private func setupCornerShadow() {
        firstAbilityView.layer.cornerRadius = 6.0
        firstAbilityView.clipsToBounds = true
        secondAbilityView.layer.cornerRadius = 6.0
        secondAbilityView.clipsToBounds = true
        
        detailContentView.layer.cornerRadius = 12.0
        detailContentView.clipsToBounds = true
        detailContentView.setShadow()
    }
    
    private func setupBackButton() {
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in guard
                let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
}

// MARK: - Catch Action
extension PokemonDetailViewController {
    private func setupCatchButton() {
        if viewModel.isCaught {
            catchButton.backgroundColor = UIColor.lightGray
            catchButton.setTitle(PokemonDetailViewModel.EnumTitleLabel.release, for: .normal)
        }
        
        catchButton.rx.tap
            .subscribe(onNext: { [weak self] in guard
                let self = self else { return }
                if self.viewModel.isCaught {
                    self.setupReleaseAction()
                } else {
                    self.setupCatchAction()
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupTryAgainButton() {
        tryAgainButton.rx.tap
            .subscribe(onNext: { [weak self] in guard
                let self = self else { return }
                if self.viewModel.isCaught {
                    self.setupReleaseAction()
                } else {
                    self.setupCatchAction()
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupCatchAction() {
        setupLoadingImage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in guard
        let self = self else { return }
            let isCaughtPokemon = self.chanceReactionPokemon(chance: self.viewModel.chance)
            self.loadingCatchImageView.image = isCaughtPokemon ? UIImage(named: "success") : UIImage(named: "failed")
            self.setupCaughtPokemonView(isCaught: isCaughtPokemon)
        }
    }
    
    private func setupReleaseAction() {
        setupLoadingImage(isRelease: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in guard
            let self = self else { return }
            let isReleasePokemon = self.chanceReactionPokemon(chance: self.viewModel.chance)
            self.loadingCatchImageView.image = isReleasePokemon ? UIImage(named: "success") : UIImage(named: "failed")
            self.setupReleasePokemonView(isRelease: isReleasePokemon)
        }
    }
    
    private func chanceReactionPokemon(chance: Int) -> Bool {
        var rngData = [Int]()
        for x in 1...100 {
            rngData.append(x <= chance ? 1 : 0)
        }
        rngData.shuffle()
        let rngIndex = Int.random(in: 0...rngData.count - 1)
        print(rngData[rngIndex])
        
        return rngData[rngIndex] == 1
    }
    
    private func setupLoadingImage(isRelease: Bool = false) {
        loadingCatchImageView.loadGif(name: "rng")
        tryAgainButton.isHidden = true
        detailContentView.isHidden = true
        resultView.isHidden = false
        
        let enumLabel = PokemonDetailViewModel.EnumTitleLabel.self
        messageLabel.text = isRelease ? enumLabel.loadingReleaseMessage : enumLabel.loadingCatchMessage
    }
    
    private func setupCaughtPokemonView(isCaught: Bool) {
        let enumLabel = PokemonDetailViewModel.EnumTitleLabel.self
        messageLabel.isHidden = !isCaught
        tryAgainButton.isHidden = isCaught
        messageLabel.text = enumLabel.successMessage
        
        if isCaught {
            self.savePokemon()
        }
    }
    
    private func setupReleasePokemonView(isRelease: Bool) {
        let enumLabel = PokemonDetailViewModel.EnumTitleLabel.self
        messageLabel.isHidden = !isRelease
        tryAgainButton.isHidden = isRelease
        messageLabel.text = enumLabel.successMessage
        
        if isRelease {
            self.releasePokemon(name: self.viewModel.name)
        }
    }
}

// MARK: - UIGestureDelegate
extension PokemonDetailViewController: UIGestureRecognizerDelegate {
    private func addSwipeBack() {
        viewModel.isSwipeBack = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func removeSwipeBack() {
        guard self.viewModel.isSwipeBack else { return }
        
        self.viewModel.isSwipeBack = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer
    }
}

// MARK: - Core Data
extension PokemonDetailViewController {
    private func savePokemon() {
        let context: NSManagedObjectContext = viewModel.appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "PokemonData", in: context)
        let newPokemon = PokemonData(entity: entity!, insertInto: context)
        newPokemon.name = viewModel.name
        newPokemon.imageURL = viewModel.imageURL
        newPokemon.hp = Int64(viewModel.hp)
        newPokemon.cp = Int64(viewModel.cp)
        newPokemon.firstAbility = viewModel.firstAbility
        newPokemon.secondAbility = viewModel.secondAbility
        
        do {
            try context.save()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            print(Constants.ERROR_SAVE_CORE_DATA)
        }
    }
    
    func releasePokemon(name: String) {
        let context: NSManagedObjectContext = viewModel.appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let pokemon = try context.fetch(fetchRequest).first
            if let pokemon = pokemon {
                deletePokemon(pokemon: pokemon)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                print("Pokemon not found")
            }
        } catch {
            print(Constants.ERROR_SAVE_CORE_DATA)
        }
    }
    
    private func deletePokemon(pokemon: PokemonData) {
        let context: NSManagedObjectContext = viewModel.appDelegate.persistentContainer.viewContext
        
        context.delete(pokemon)
        
        do {
            try context.save()
        } catch {
            print(Constants.ERROR_SAVE_CORE_DATA)
        }
    }
}
