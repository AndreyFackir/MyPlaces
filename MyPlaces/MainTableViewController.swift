//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 18.05.2022.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    
    let restaurantNames = ["Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "IndoKitay",
                           "X.O", "Balkan Grill", "Sherlock Holmes", "Speak Easy", "Morris Pub", "Tasty Stories", "Classic",
                           "Love&Life", "Shock", "Bochka"]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurantNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        
        cell.textLabel?.text = restaurantNames[indexPath.row]
        cell.imageView?.image = UIImage(named: restaurantNames[indexPath.row])
        //cделали круглым только imageView
        //высоту строки делим на 2
        cell.imageView?.layer.cornerRadius = cell.frame.size.height / 2
        //обрезаем изображение пограницам ImageView
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    //MARK: - TableViewDelegate
    
    // высота строки
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
