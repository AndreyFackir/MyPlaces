//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 18.05.2022.
//

import UIKit
import RealmSwift

class MainTableViewController: UITableViewController {
    
    //Results - автообновляемый тип контейнера который возвращает запрашиваемые объекты
    //Results - аналог массива
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()

        //чтобы отобразить все, надо инициализировать объект places
        //чтобы сделать запрос объектов, обратимся к глобальному свойству рилм и вызываем метод обжектс указав в качестве параметра Плейс(сам тип данных)
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.isEmpty ? 0 : places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //нужен для  того, чтобы мы могли на него сослаться при нажатии на кнопку cancel и вернуться на MainTableViewController
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        //параметр destination используем, когда мы хотим передать данные от ВС с которого переходим ВС на который переходим
        
        //сейчас мы выполняем возврат с ВС на который переходили ранее, поэтому используем анвинд и свойство соурс
        
        guard let newPlaceVC = segue.source  as? NewPlaceViewController else {return}
        
        newPlaceVC.saveNewPlace()
       // places.append(newPlaceVC.newPlace!)
        
        //обновляем интерфейс
        tableView.reloadData()
        
    }
}
