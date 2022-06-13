//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 18.05.2022.
//

import UIKit
import RealmSwift

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //для работы с UISearchController
    //передавая нил мы говорим контроллеру поиска что для отображения результат хотим использовать тот же вью, в котором отображается основной контент
    //для этого класс мейнВС должен быть подписан под протокол
    private let searchController = UISearchController(searchResultsController: nil)
    
    //Results - автообновляемый тип контейнера который возвращает запрашиваемые объекты
    //Results - аналог массива c типом Place
    private var places: Results<Place>!
    
    //для отображения поискового запроса, понадобится еще один массив, куда будем помещать отфильрованные записи
    private var filteredPlaces: Results<Place>!
    
    // чтобы сортировалось в обратном порядке
    private var ascendingSorted = true
    
    //еще одно логисческое свойсвто, которе бдует возвращать тру или фолс в зависимости от того, пустая строка поиска или нет
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    
    //для остлеживания активации поискового запроса
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
   

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //чтобы отобразить все, надо инициализировать объект places
        //чтобы сделать запрос объектов, обратимся к глобальному свойству рилм и вызываем метод обжектс указав в качестве параметра Плейс(сам тип данных)
        places = realm.objects(Place.self)

            // setup search Controller
        //получателем информации об изменение в поисковой строке бдует наш класс
        searchController.searchResultsUpdater =  self
        
        //позволит взаимодействовать с нашим контроллером как с основным
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search"
        //присвоим строку поиска в навигейшн бар
        navigationItem.searchController = searchController
        //позволяет отпустить строку поиска при переходе на другой экран
        definesPresentationContext = true
        
    }

    // MARK: - Table view data source

    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
         if isFiltering{
             return filteredPlaces.count
         }
         
        // #warning Incomplete implementation, return the number of rows
        return places.isEmpty ? 0 : places.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //чтобы использовать отдельный класс для ячейки даункастим ее через as!
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        // Configure the cell...
         
         //cоздаем экз модели, чтобы присвоить ему значения из того илил иного массива
            var place = Place()
         
         if isFiltering{
             place = filteredPlaces[indexPath.row]
         } else {
             place = places[indexPath.row]
         }

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type

        //какое изображение присваиваем ячейке
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
       
      

        //cделали круглым только imageView
        //высоту строки делим на 2
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        //обрезаем изображение по границам ImageView
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
            let place: Place
            if isFiltering{
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            
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
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        //заменим все ниже написанное
        
        sorting()
        
//        // если индек выбранного сегмента == 0
//        if sender.selectedSegmentIndex == 0 {
//            // то сортируем по дате в порядке возрастания
//            places = places.sorted(byKeyPath: "date")
//        } else {
//            places = places.sorted(byKeyPath: "name")
//        }
//
//        //после выбора сегмента обновляем таблицу
//        tableView.reloadData()
//
        
        
    }
    @IBAction func reversedSorting(_ sender: Any) {
        
        //меняем значение свойтсва
        ascendingSorted.toggle()
        
        
        if ascendingSorted {
            //при смене значения ascendingSorted меняем изображение кнопки
            reversedSortingButton.image = UIImage(named: "AZ")
        } else {
            reversedSortingButton.image = UIImage(named: "ZA")
        }
        
        sorting()
    }
    
    //чтобы выполнить сортировку используем ту же логику что и при сегментед котроле
    //чтобы не повторяться сделаем привтаный метод
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorted)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorted)
        }
        
        tableView.reloadData()
    }
}

extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // можно сделать форс анрап, тк метод вызывается только тогда когда тапаем по поисковой строке
        filterContentForSearchtext(searchController.searchBar.text!)
    }
    
    //для работы с поисковыми запросами объявим метод, который будет заниматься фильтрацией контента в сотв с поисковым запросом
    private func filterContentForSearchtext(_ searchText: String) {
        
        // заполняем коллекцию отфильтрованными обхектами из основномго массива плейсис
        // из реалма CONTAINS
        //[c] значит что мы не смотрим на регистр символов
        //%@ туда подставляем конкретную переменную
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
    
}
