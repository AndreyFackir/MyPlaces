//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 22.05.2022.
//

import RealmSwift

//Для работы с базой надо создать объект, который будет предоставлять доступ к базе данных
//создаем глобальную переменную
let realm = try! Realm()


class StorageManager {
    
    //метод для добавления в базу
    static func saveObject(_ place: Place) {
        
        //realm - точка входа в базу данных
        try! realm.write {
            realm.add(place)
        }
    }
    
    
    //реализуем меод для удаления объектов из базы данных
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
    
    //
}
