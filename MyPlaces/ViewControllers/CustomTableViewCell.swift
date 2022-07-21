 //
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 19.05.2022.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false // отключаем возможность изменять количесвто звезд на главном экране
        }
    }
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            
            //cделали круглым только imageView
            //высоту строки делим на 2
            imageOfPlace?.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            //обрезаем изображение по границам ImageView
            imageOfPlace?.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
}
