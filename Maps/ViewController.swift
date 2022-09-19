//
//  ViewController.swift
//  Maps
//
//  Created by Auriga on 16/09/22.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textFieldForAddress: UITextField!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        mapView.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locations[0].coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    @IBAction func GetDirections(_ sender: Any) {
        getAddress()
    }
    
    func getAddress() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textFieldForAddress.text!) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location
            else {
                print("No Location Found")
                return
            }
            print(location)
            self.mapThis(destinationCord: location.coordinate)
        }
    }
                
    func mapThis(destinationCord : CLLocationCoordinate2D) {
        if locationManager.location?.coordinate != nil {
            let sourceCordinate = (locationManager.location?.coordinate)!
            let soucePlaceMark = MKPlacemark(coordinate: sourceCordinate)
            let destPlaceMark = MKPlacemark(coordinate: destinationCord)
            let sourceItem = MKMapItem(placemark: soucePlaceMark)
            let destItem = MKMapItem(placemark: destPlaceMark)
            let destinationRequest = MKDirections.Request()
            destinationRequest.source = sourceItem
            destinationRequest.destination = destItem
            destinationRequest.transportType = .automobile
            destinationRequest.requestsAlternateRoutes = true
            let directions = MKDirections(request: destinationRequest)
            directions.calculate {(response, error) in
                guard let response = response else { return }
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }else {
            showtoast(controller: self, message: "Please turn on your location", second: 2)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
    func showtoast(controller : UIViewController , message : String , second : Double) {
        var preferredStyle: UIAlertController.Style  = .actionSheet
        if UIDevice.current.userInterfaceIdiom == .pad {
            preferredStyle = .alert
        }
        let alert = UIAlertController(title : nil , message: message , preferredStyle: preferredStyle)
        controller.present(alert , animated: true , completion: nil)
        Timer.scheduledTimer(withTimeInterval: second, repeats: false) { Timer in
            alert.dismiss(animated: true)
        }
    }
}

