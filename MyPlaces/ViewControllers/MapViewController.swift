

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    let annotationIdentifier = "annotationIdentifier"
    
    var place = Place()
    let locationManager = CLLocationManager() //отвечает за настройку и управление службы геолокаций
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
       checkLocationServices()
        
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
    
    //проверяем включены ли службы гео на устройстве
    private func checkLocationServices() {
        
        //если службы гео доступны
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //show alert
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        //определим точность места юзера
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //максимальная точность
        
    }
    
    //проверка статуса на разрешение использования геопозиции
    private func checkLocationAuthorization() {
        //
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: //разрешено определять гео в момент использования
            mapView.showsUserLocation = true //отображаем местоположение юзера
            break
        case .denied: //приложению отказано в доступе к гео, либо они откл в настройках
            //необходимо объяснить юзеруу как включить через алерт
            break
        case .notDetermined: //статус не определен
            locationManager.requestWhenInUseAuthorization() //спрашиваем разрешение на использование гео в момент использования приложения
            break
        case .restricted: //возвращается если приложение не авторизовано для использования служб гео
            //shoe alert
            break
        case.authorizedAlways:
            break
            
        @unknown default:
            print("New case is available")
        }
    }
}
//MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    //отвечает за отображение аннтоаций
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // если аннтотация показывает текущее полоожение юзера, то не нужна аннтотация
        guard !(annotation is MKUserLocation) else { return nil}
        
        //создаем объект класса который представляет вью с аннтотацией на карте
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView //даункасти чтобы баннер отображался с булавкой
        
        //еси на карте нет представления с аннтотацией, то инитим новое значение
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        //чтобы отобразить аннтоттацию в виде баннера
        annotationView?.canShowCallout = true
        
        if let imageData = place.imageData {
            //добавляем на баннере изображение заведения
            let imageVIew = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) // 50 - так как это высота баннера
            imageVIew.layer.cornerRadius = 10
            imageVIew.clipsToBounds = true
            imageVIew.image = UIImage(data: imageData)
            
            annotationView?.rightCalloutAccessoryView = imageVIew //ставим справа на баннере изображение
        }
        
        
        return annotationView
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    //вызывается при смене статуса авторизации для использования гео
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
       
        }
    }

