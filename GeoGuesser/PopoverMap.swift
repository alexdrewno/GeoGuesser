import UIKit
import GoogleMaps


//Creates all the details for the small map, not too hard to understand

class PopoverMap: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var guessMapView: UIView!
    let camera = GMSCameraPosition.camera(withLatitude: 40.913513 , longitude: -99.228516, zoom: 3.1)
    var mapView : GMSMapView! = nil
    @IBOutlet var navBar: UINavigationBar!
    var senderVC : GameViewController! = nil
    let marker = GMSMarker()
    let marker2 = GMSMarker()
    var locationName : String!
    var answerLocation : CLLocationCoordinate2D!
    var markerPlaced = false
    var marker2Placed = false
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var makeGuess: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navBar.backgroundColor = UIColor.white
        guessMapView.clipsToBounds = true
        guessMapView.layer.cornerRadius = 10
        guessMapView.layer.shadowColor = UIColor.black.cgColor
        guessMapView.layer.shadowOpacity = 0.6
        guessMapView.layer.shadowRadius = 15
        guessMapView.layer.shadowOffset = CGSize(width: 5, height: 5)
        mapView = GMSMapView.map(withFrame: CGRect(x: 10, y: 50, width: guessMapView.frame.width-20, height: guessMapView.frame.height-60), camera: camera)
        guessMapView.addSubview(mapView)
        mapView.delegate = self
        marker.title = "Guess"
        marker.map = mapView
        
        marker2.title = "Answer"
        marker2.snippet = locationName
        marker2.map = mapView
        
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        
     self.dismiss(animated: true, completion: nil)
       senderVC.unwindFromSecondary()
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        if !marker2Placed
        {
            marker.position = coordinate
            markerPlaced = true
        }

    }

    @IBAction func makeGuess(_ sender: AnyObject) {
        

        let alertView = UIAlertController(title: "Confirm", message: "Is this your guess?", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in

            
            self.cancelButton.isEnabled = false
            self.makeGuess.isEnabled = false
            self.marker2.position = self.answerLocation
            self.marker2Placed = true
            self.mapView.selectedMarker = self.marker2
            let path = GMSMutablePath()
            path.add(self.marker.position)
            path.add(self.marker2.position)
            let rectangle = GMSPolyline(path: path)	
            rectangle.map = self.mapView
            let bounds = GMSCoordinateBounds(path: path)
            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 80.0))
            
            if self.markerPlaced
            {
                let path = GMSMutablePath()
                path.addLatitude(self.marker.position.latitude, longitude: self.marker.position.longitude)
                path.addLatitude(self.marker2.position.latitude, longitude: self.marker2.position.longitude)
                let polyline = GMSPolyline(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.green
                polyline.map = self.mapView
                
                let distance = path.length(of: kGMSLengthGeodesic)
                print(distance)
                
                var points = distance / 1000
                points = 2000000/points
                if points > 15000
                {
                    points = 15000
                }
                print(Int(points))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    let alertC = UIAlertController(title: "The answer was: \n \(self.locationName as NSString)", message: "You earned \(Int(points)) points that round!", preferredStyle: .alert)
                    alertC.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (alert:UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                        self.senderVC.unwindFromSecondary()
                        if self.senderVC.round < 5
                        {
                            
                            self.senderVC.round += 1
                            self.senderVC.roundLabel.text = "Round \(self.senderVC.round)/5"
                            self.senderVC.points += Int(points)
                            self.senderVC.pointsLabel.text = "Points: \(self.senderVC.points)"
                            self.senderVC.getNewLocation()
                        }
                        else
                        {
                            self.senderVC.points += Int(points)
                            self.senderVC.pointsLabel.text = "Points: \(self.senderVC.points)"
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { 
                                    self.senderVC.newGame()
                            })
                            
                            
                        }
                        
                    }))
                    self.present(alertC, animated: false, completion: nil)
                })
            }
            
            
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertView, animated: false, completion: { 
            
        })

        
    }
}
