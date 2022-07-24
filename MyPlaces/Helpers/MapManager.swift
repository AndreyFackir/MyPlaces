//
//  MapManager.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 21.07.2022.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager() //отвечает за настройку и управление службы геолокаций
    
    //хранение маршрутов
    private var directionsArray: [MKDirections] = []
    
    private let regionInMeters = 1000.0
    //свойство, принимающее координаты заведения
    private var placeCoordinate: CLLocationCoordinate2D?
    
    //отображение объекта на карте( маркер указывающий метсо на карте)
     func setupPlacemark(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            //привязываем аннтотацию к конкретной точке на карте
            //нужно определить место маркера
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            //передаем коорд новому свойству
            self.placeCoordinate = placemarkLocation.coordinate
            
            //задаем видимую область ос всеми созданными аннтотациями
            mapView.showAnnotations([annotation], animated: true)
            //выделяем созданную аннтотацию
            mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    //проверяем включены ли службы гео на устройстве
     func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        
        //если службы гео доступны
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            //show alert
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(title: "Location Services are disable",
                               message: "")
            }
            
        }
    }
    
     func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        //present(alert, animated: true) //так как класс MapManager не имеет общего с вьюконтроллерами, то мы не м ожем вызывать метод презент
        let alertWindow = UIWindow(frame: UIScreen.main.bounds) //окно по границе экрана
        alertWindow.rootViewController = UIViewController()
        //определяем позиционирование данного окна относитлеьно других окон
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
    //проверка статуса на разрешение использования геопозиции
     func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse: //разрешено определять гео в момент использования
            mapView.showsUserLocation = true //отображаем местоположение юзера
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        case .denied: //приложению отказано в доступе к гео, либо они откл в настройках
            //необходимо объяснить юзеруу как включить через алерт
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To enable your location tracking: Setting -> MyPlaces -> Location"
                )
            }
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
    // Фокус карты на местоположении пользователя
     func showUserLocation(mapView: MKMapView) {
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
    
    //прокладываем маршрут
    // Строим маршрут от местоположения пользователя до заведения
     func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        //определим коорд пользоватлея
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current Location is not found")
            return
        }
        
        //вызываем режим постоянного отслеживания текущего места юзера
        locationManager.startUpdatingLocation()
        //передаем текцщие координаты места юзера
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        //выполняем запрос на прокладку маршрута
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        //если все хорошо, создаем маршрут на основе сведений, которые есть в запросе
        let directions = MKDirections(request: request)
        
        //вызывается перед тем как создать новый маршрут, удаляя текущие маршруты
        resetMapView(withNew: directions, mapView: mapView)
        
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
                mapView.addOverlay(route.polyline) // создаем доп наложение со всеми доступными маршрутами
                //polyline - представляет подробную геометрию всего маршрута
                //сфокусиируем карту, чтобы весь маршрут был виден целиком
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) //определяет зону видимости карты
                
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
     func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        
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
    
    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    //слежение за изменение места юзера и позиционирование карты по его коорд
     func startTrackinUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        
        //коорд центра области
        let center = getCenterLocation(for: mapView)
        
        //если расстояние от предыдущего места юезра до центра отображемой области больше 50 м
        guard center.distance(from: location) > 50 else { return }
        
        
        //вызываем метод чтобы спозиционировать карту с текцщим местом юзера
        closure(center)
        
        
    }
    
    //если меняем маршрут, то при перестроении маршруты буду наклдываться друг на друга
    //для этого будем удалять маршруты наложение текущего маршрута
    //вызывается перед тем как создать новый маршрут
     func resetMapView( withNew directions: MKDirections, mapView: MKMapView) { //отменяет все действующие маршруты и удаляет с карты
        mapView.removeOverlays(mapView.overlays)
        
        //добавляем в массив текущий маршрут
        directionsArray.append(directions) //из параметров метода
        
        let _ = directionsArray.map {$0.cancel()} //проходимся по каждому элементу и вызываем кенсел
        directionsArray.removeAll()
    }
    
    //определение координат под пином( центром отображаемой области карты)
     func getCenterLocation( for mapView: MKMapView) -> CLLocation {
        //CLLocation -  координаты( чтобы определить надо знать широту и долготу)
        
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
        
        
    }
    
    deinit {
        print("deinit", MapManager.self)
    }
}

