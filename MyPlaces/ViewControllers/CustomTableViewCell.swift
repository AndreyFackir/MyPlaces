 //
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 19.05.2022.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cosmosView: CosmosView!
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
}
