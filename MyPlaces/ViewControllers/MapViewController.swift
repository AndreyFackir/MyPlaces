

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    var place: Place! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()
       
    }
   
    
    //закрываем экран с картой
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
    }
    
    //отображение объекта на карте( маркер указывающий метсо на карте)
    private func setupPlacemark() {
        //извлекаем адресс заведения
        guard let location = place.location else { return }
        
        //позволяет преобразовать геокоординат и названия( ширину и долготу в название города и тд)
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            //создаем новый массив
            guard let placemarks = placemarks else { return }
            //так как ищем место по конкретному адресу, присваиваем первое значение массива(одна метка)
            let placemark = placemarks.first // получили метку
            
            let annotation = MKPointAnnotation() //используется для описания точки на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            //привязываем аннтотацию к конкретной точке на карте
            //нужно определить место маркера
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            //задаем видимую область ос всеми созданными аннтотациями
            self.mapView.showAnnotations([annotation], animated: true)
            //выделяем созданную аннтотацию
            self.mapView.selectAnnotation(annotation, animated: true)
            
            
            
        }
    }
}
