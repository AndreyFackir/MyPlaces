//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 19.05.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //чтобы избавиться от лишних сепараторов в таблице
        //tableView.tableFooterView = UIView()

    }

   //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //если ячейка имеет индекс ноль, то вызываем меню для выбора изображения
        if indexPath.row == 0 {
            
            //вызываем меню при нажатии на ячейку с индексом 0 (фото)
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            //определим список пользовательских действий - камера, фото, кнопка кенсел
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                
                //вызываем метод, чтобы сделать фото
                self.chooseImagePicker(source: .camera)
                
                //необходимо запросить разрешение у п ользователя на использование камеры
                //для этого добавим ключ NSCameraUsageDescription  в  настройках plist
                
            }
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                
                //вызываем метод, чтобы выбрать фото
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            //отменяет вызов меню
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            //необходимо вызывать алерт вьюконтроллер
            present(actionSheet, animated: true)
            
        } else {
            //скрываем клаву по тапу за пределами первой ячейки
            view.endEditing(true)
        }
    }

}

//MARK: - Text Field Delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    //скрываем клаву по нажатию на done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Work with images

extension NewPlaceViewController {
    
    //параметр сорс определяет источник выбора изображения
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        //проверка на доступность выбора изображений
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            //создаем экз класса
            let imagePicker = UIImagePickerController()
            //позволит юзеру редактировать выбранное изображение
            imagePicker.allowsEditing = true
            
            //определяем тип источника для выбора изображений
            imagePicker.sourceType = source
            
            //так как imagePicker является viewController, поэтому нам надо вызвать метод пресент, чтобы отобразить его
            
            present(imagePicker, animated: true)
            
        }
    }
}
