//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 19.05.2022.
//

import RealmSwift
// в качестве моделей используют структуры , так как кони не требуют создания инитов

class Place: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    
    //так как у нас будет сортировка по дате, то добавим поле с типом дейт
    // необходимо для внутреннего использования
    @objc dynamic var date = Date()
    
    // convinience - назначенный инииализатор, предназанченный для того, чтобы полностью инитить все свойства представленные классом
   
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        //такой инициализатор должен вызывать инит самого класса с пустыми параметрами
        //для того, чтобы мы иниццииализировали все свойства значениями по умолчанию
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        
    }
    
}
    
//    func savePlaces() {
//
//        for place in restaurantNames {
//
//            //чтобы присвоить изображения свойству имедж, надо перевести его тип в тип Data
//            let image = UIImage(named: place)
//
//            //метод pngData позволяет сконвертировать изображение в тип Data
//            guard let imageData = image?.pngData() else {return}
//
//
//
//            let newPlace = Place()
//            newPlace.name = place
//            newPlace.location = "SPB"
//            newPlace.type = "Restaurant"
//            newPlace.imageData = imageData
//
//            StorageManager.saveObject(newPlace)
//
//        }
//
//    }
//
//}
