

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {
    
   
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
   
    
    //закрываем экран с картой
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
    }
}
