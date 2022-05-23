//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 19.05.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    
   
    var imageIsChanged = false
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //чтобы избавиться от лишних сепараторов в таблице
        //tableView.tableFooterView = UIView()
        
        //по умолчанию кнопка сейв будет отключена
        saveButton.isEnabled = false
        
        //отслеживаем внесение данных в поле текстфилд
        // метод textFieldChanged будет вызываться при редактировании (editingChanged) текстфилд
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
       

    }

   //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //если ячейка имеет индекс ноль, то вызываем меню для выбора изображения
        if indexPath.row == 0 {
            
            
            //создаем 2 объекта с изображениями
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photo")
            
            //вызываем меню при нажатии на ячейку с индексом 0 (фото)
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            //определим список пользовательских действий - камера, фото, кнопка кенсел
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                
                //вызываем метод, чтобы сделать фото
                self.chooseImagePicker(source: .camera)
                
                //необходимо запросить разрешение у п ользователя на использование камеры
                //для этого добавим ключ NSCameraUsageDescription  в  настройках plist
                
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            //располагаем заголовки меню по левому краю
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                
                //вызываем метод, чтобы выбрать фото
                self.chooseImagePicker(source: .photoLibrary)
            }
            // позволяет установить значение любого типа по ключу
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
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

    func saveNewPlace() {
        
       
        var image: UIImage?
        
        //если картинку выбрал пользователь
        if imageIsChanged {
            
            image = placeImage.image
        } else {
            //присваиваем дефолтную картинку
            image = UIImage(named: "imagePlaceholder")
        }
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)
        
        StorageManager.saveObject(newPlace)
        
    }
    
    @IBAction func cancelACtion(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

//MARK: - Text Field Delegate

extension NewPlaceViewController: UITextFieldDelegate, UINavigationControllerDelegate {
    
    //скрываем клаву по нажатию на done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //private будет использоваться только в этом классе
    @objc private func textFieldChanged() {
        
        //если  текстовое поле не пустое
        if placeName.text?.isEmpty ==  false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

//MARK: - Work with images

extension NewPlaceViewController: UIImagePickerControllerDelegate {
    
    //параметр сорс определяет источник выбора изображения
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        //проверка на доступность выбора изображений
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            //создаем экз класса
            let imagePicker = UIImagePickerController()
            
            //делегировать выполнение метода imagePickerController должен объект с типом UIImagePickerController
            //imagePicker будет делегировать обязанности по выполнению
            
            //определяем объект, который будет выполнять данный метод( назначаем делегата)
            imagePicker.delegate = self
            
            //позволит юзеру редактировать выбранное изображение
            imagePicker.allowsEditing = true
            
            //определяем тип источника для выбора изображений
            imagePicker.sourceType = source
            
            //так как imagePicker является viewController, поэтому нам надо вызвать метод пресент, чтобы отобразить его
            
            present(imagePicker, animated: true)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //присваиваем изображение, которое выбирает юзер
        //берем значение по ключу словаря инфо
        //приводим к типу UIImage
        placeImage.image = info[.editedImage] as? UIImage
        //позволяет маштабировать изображение по границам UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        //если картинку поставли сами то меняем на тру
        imageIsChanged = true
            //закрыаем контроллер
        dismiss(animated: true)
    }
}
