//
//  PokemonData+CoreDataProperties.swift
//  
//
//  Created by Geadalfa Giyanda on 03/08/23.
//
//

import Foundation
import CoreData


extension PokemonData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonData> {
        return NSFetchRequest<PokemonData>(entityName: "PokemonData")
    }

    @NSManaged public var cp: Int64
    @NSManaged public var firstAbility: String?
    @NSManaged public var hp: Int64
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var secondAbility: String?

}
