

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
    
    //после написания протокола создаем свойство с типом протокола( делегат класса)
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    @IBOutlet var mapView: MKMapView!
   
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    @IBOutlet weak var mapPinImage: UIImageView!
    
    //свойство, принимающее координаты заведения
    var placeCoordinate: CLLocationCoordinate2D?
    //свойство для хранения предыдущего местоположения пльзователя
    var previousLocation: CLLocation? {
        didSet {
            //слежение за изменение места юзера и позиционирование карты по его коорд
            startTrackinUserLocation()
        }
    }
    
    //хранение маршрутов
    var directionsArray: [MKDirections] = []
    
    let regionInMeters = 1000.0
    
    // в зависимости от значения индентификатора мы будем вызывать либо setupPlacemark(), либо showUserLocation
    var incomeSegueIdentifier = ""
    
    let annotationIdentifier = "annotationIdentifier"
    
    var place = Place()
    let locationManager = CLLocationManager() //отвечает за настройку и управление службы геолокаций
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
       //addressLabel.text = "" //чтобы при загрузке карт не мелькало название лейбла по умолчанию
        
        
    }
   
    //по нажатию центрируется местоположение юзера
    @IBAction func centerViewUSerLocation() {
        
        showUserLocation()
        
    }
    
    @IBAction func doneButtonPressed() {
        //передаем данные по нажатию на кнопку на другой экран через протокол( делегат)
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    //закрываем экран с картой
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
    }
    
    //позиционирование карты если идентиифкатор showPlace
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            //скрываем маркер( pin) при переходе по сигвею showPlace
            mapPinImage.isHidden = true
            setupPlacemark()
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    //если меняем маршрут, то при перестроении маршруты буду наклдываться друг на друга
    //для этого будем удалять маршруты наложение текущего маршрута
    //вызывается перед тем как создать новый маршрут
    private func resetMapView( with directions: MKDirections) { //отменяет все действующие маршруты и удаляет с карты
        mapView.removeOverlays(mapView.overlays)
        
        //добавляем в массив текущий маршрут
        directionsArray.append(directions) //из параметров метода
        
        let _ = directionsArray.map {$0.cancel()} //проходимся по каждому элементу и вызываем кенсел
        directionsArray.removeAll()
    }
    
    //прокладываем маршрут
    private func getDirections() {
        
        //определим коорд пользоватлея
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current Location is not found")
            return
        }
        
        //вызываем режим постоянного отслеживания текущего места юзера
        locationManager.startUpdatingLocation()
        //передаем текцщие координаты места юзера
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        //выполняем запрос на прокладку маршрута
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        //если все хорошо, создаем маршрут на основе сведений, которые есть в запросе
        let directions = MKDirections(request: request)
        
        //вызывается перед тем как создать новый маршрут, удаляя текущие маршруты
        resetMapView(with: directions)
        
        //запускем расчет маршрута
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            //обЪект респонс содержит массив с маршрутами
            for route in response.routes {
                self.mapView.addOverlay(route.polyline) // создаем доп наложение со всеми доступными маршрутами
                //polyline - представляет подробную геометрию всего маршрута
                //сфокусиируем карту, чтобы весь маршрут был виден целиком
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) //определяет зону видимости карты
                
                //определим расстояние
                let distance = String(format: "%.1f" , route.distance / 1000)
                
                //время в пути
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места - \(distance) км")
                print("Время в пути - \(timeInterval) сек")
            }
        }
    }
    
    //метод с настройками запроса для построения маршрута
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        
        //передаем коорд заведения
        guard let destinationCoordinate = placeCoordinate else { return nil }
        
        //определим местоположение точки для начала маршрута
        //зависит от местоположения пользователя, которое мы передадим в параметр функции
        let startingLocation = MKPlacemark(coordinate: coordinate)
        
        //определим конечную точку
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        //имея начальную и конечную точки сможем создать запрос на построение маршрута
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        
        //для построения маршрута надо задать тип транспорта
        request.transportType = .automobile
        request.requestsAlternateRoutes = true //позволяеет строить нескольок маршрутов
        
        return request
             
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
            
            //передаем коорд новому свойству
            self.placeCoordinate = placemarkLocation.coordinate
            
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(title: "Location Services are disable",
                               message: "")
            }
            
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
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
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
    
    //при переходе по сигвею getAddress
    private func showUserLocation() {
        // центрируется местоположение юзера
        //если можем определить коорд польщователя
        if let location = locationManager.location?.coordinate {
            //определяем регион для позиционирования юзера
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            
             //устанавливаем регион для отображения на экране
            mapView.setRegion(region, animated: true)
        }
    }
    
    //слежение за изменение места юзера и позиционирование карты по его коорд
    private func startTrackinUserLocation() {
        guard let previousLocation = previousLocation else { return }
        
        //коорд центра области
        let center = getCenterLocation(for: mapView)
        
        //если расстояние от предыдущего места юезра до центра отображемой области больше 50 м
        guard center.distance(from: previousLocation) > 50 else { return }
        //зададим новые коорд предыдущему места юзера = текцщим коорд центра
        self.previousLocation = center
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            //вызываем метод чтобы спозиционировать карту с текцщим местом юзера
            self.showUserLocation()
        }
        
    }
    
    //определение координат под пином( центром отображаемой области карты)
    private func getCenterLocation( for mapView: MKMapView) -> CLLocation {
        //CLLocation -  координаты( чтобы определить надо знать широту и долготу)
        
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
        
        
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
        
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
        let center = getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder() //отвечает за преобразование координат и гео названий
        
        //если переходим по сигвею showPlaceб позиционируем карту по месту юзера
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
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
        checkLocationAuthorization()
       
        }
    }

