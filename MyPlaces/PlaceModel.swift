//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 19.05.2022.
//

import Foundation
// в качестве моделей используют структуры , так как кони не требуют создания инитов

struct Place {
    
    var name: String
    var location: String
    var type: String
    var image: String
    
    static let restaurantNames = ["Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "IndoKitay",
                              "X.O", "Balkan Grill", "Sherlock Holmes", "Speak Easy", "Morris Pub", "Tasty Stories", "Classic",
                              "Love&Life", "Shock", "Bochka"]
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Saint Petersburg", type: "Restaurant", image: place))
        }
        
        return places
    }
    
}