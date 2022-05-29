//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 18.05.2022.
//

import UIKit
import RealmSwift

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Results - автообновляемый тип контейнера который возвращает запрашиваемые объекты
    //Results - аналог массива
    var places: Results<Place>!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //чтобы отобразить все, надо инициализировать объект places
        //чтобы сделать запрос объектов, обратимся к глобальному свойству рилм и вызываем метод обжектс указав в качестве параметра Плейс(сам тип данных)
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.isEmpty ? 0 : places.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //чтобы использовать отдельный класс для ячейки даункастим ее через as!
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        // Configure the cell...

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type

        //какое изображение присваиваем ячейке
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
       
      

        //cделали круглым только imageView
        //высоту строки делим на 2
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        //обрезаем изображение пограницам ImageView
        cell.imageOfPlace?.clipsToBounds = true



        return cell
    }
    
    //MARK: - TableViewDelegate
    
    
    //удаление объектов из таблицы и базы данных
    
    /*
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
       
        
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
            let place = self.places[indexPath.row]
            StorageManager.deleteObject(place)
            boolValue(true)
        }
        let deleteAction = UISwipeActionsConfiguration(actions: [contextItem])
       
        return deleteAction
    }
    
    */
    
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
        return [deleteAction]
    }
   
//    // высота строки
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//
//    }
    
//MARK: - Naavigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "showDetail" {
            //когда тапаем по ячейке нам надо передать объект из ячейки на другой ВС
            //надо извлечь конкретный объект из массива плейс
            //в массиве он хранится под индексом соответсвующий индексу текущей ячейки
            //сначала определяем индкес выбранной ячейки
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            //извлекаем объект по индексу из массива плейс
            let place = places[indexPath.row]
            
            //создаем экз ВС
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    

    //нужен для  того, чтобы мы могли на него сослаться при нажатии на кнопку cancel и вернуться на MainTableViewController
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        //параметр destination используем, когда мы хотим передать данные от ВС с которого переходим ВС на который переходим
        
        //сейчас мы выполняем возврат с ВС на который переходили ранее, поэтому используем анвинд и свойство соурс
        
        guard let newPlaceVC = segue.source  as? NewPlaceViewController else {return}
        
        newPlaceVC.savePlace()
       // places.append(newPlaceVC.newPlace!)
        
        //обновляем интерфейс
        tableView.reloadData()
        
    }
}
