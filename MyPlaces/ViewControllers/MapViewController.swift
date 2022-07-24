

import UIKit
import MapKit
import CoreLocation

//для передачи значение из mapViewController в класс NewPlaceVC
protocol MapViewControllerDelegate {
    func getAddress(_ address: String?) //@objc optional значит что метод не обязателен к реализации, сам протокол при этом тоже должен быть помечен как @objc
}

//extension MapViewControllerDelegate {
//    func getAddress(_ address: String) //если указываем расширение для протокола, то все меот ды указанные в нем будут по дефолту опциональные, т.е. необязательными к выполнению
//}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    // в зависимости от значения индентификатора мы будем вызывать либо setupPlacemark(), либо showUserLocation
    var incomeSegueIdentifier = ""
    
    //после написания протокола создаем свойство с типом протокола( делегат класса)
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    //свойство для хранения предыдущего местоположения пльзователя
    var previousLocation: CLLocation? {
        didSet {
            //слежение за изменение места юзера и позиционирование карты по его коорд
            mapManager.startTrackinUserLocation(for: mapView, and: previousLocation) { currentLocation in
                //кложер возвращает коорд центра отображаемой области
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    //MARK: - @IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    @IBOutlet weak var mapPinImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = "" //чтобы при загрузке карт не мелькало название лейбла по умолчанию
        mapView.delegate = self
        setupMapView()
        
    }
   
    //по нажатию центрируется местоположение юзера
    @IBAction func centerViewUSerLocation() {
    
        mapManager.showUserLocation(mapView: mapView)
        
    }
    
    @IBAction func doneButtonPressed() {
        //передаем данные по нажатию на кнопку на другой экран через протокол( делегат)
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { location in
            //кложер возвращает текущие коорд места юзера
            self.previousLocation = location
        }
    }
    
    //закрываем экран с картой
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
    }
    
    //позиционирование карты если идентиифкатор showPlace
    private func setupMapView() {
        
        goButton.isHidden = true
        
        //метод определяет доступность сервисов геолокаций
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            //скрываем маркер( pin) при переходе по сигвею showPlace
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
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
    
    //получаем адресс по коорднатам
    //как только регион меняется мы будем отображать адрес в цетрен региона
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // определим текцщие коорд по центру отображаемой области
        let center = mapManager.getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder() //отвечает за преобразование координат и гео названий
        
        //если переходим по сигвею showPlaceб позиционируем карту по месту юзера
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        //для освобождения ресурсов связанных с геокодированием рекомендуется делать отмену отложенного запроса
        geocoder.cancelGeocode()
        
        //преобразуем координаты в адресс
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard  let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare // название улицы
            let buildNumber = placemark?.subThoroughfare //номер дома
            
            //ОБНОВЛЯТЬ ИНТЕРФЕЙС ДОЛЖНЫ В ОСНОВНОМ ПОТОКЕ АСИНХРОННО
            DispatchQueue.main.async {
                
                //так как нзвание и номер - опциональный, проверяем
                if streetName != nil && buildNumber != nil {
                    //передаем названия в лейбл
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
               
            }
            
        }
    }
    
    //подсветить маршруты
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    //вызывается при смене статуса авторизации для использования гео
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
    }

