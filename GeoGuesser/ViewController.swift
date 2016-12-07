//
//  ViewController.swift
//  GeoGuesser
//
//  Created by adrewno1 on 10/19/16.
//  Copyright © 2016 adrewno1. All rights reserved.
//



/*
 
 1.)  The purpose of my app is to guess where in the U.S. a given panoramic view is.
 
 2.)  All I had to do is go onto the google developer website, enable street view and map view, get an api key, and use that api key in the appdelegate in this app.
 
 3.)  I didn't need any data from google, but in order to get random locations, I used a random website off the internet. I data scraped in order to get the random lat/long.
 
 4.) I put roughly 25 hours into this project, I know it's late, but I plan on releasing it to the appstore eventually.
 
 
 
 
 
 */




import UIKit
import GoogleMaps
import GoogleMobileAds

//Dimmable is a class I found on GIthub to create a fading animation for the map view and also the highscore view.
//                                                                                                                                        ||
class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, Dimmable, GMSPanoramaViewDelegate{
    
    
    var interstitial: GADInterstitial!
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var mapArea: UIView!
    var panoView : GMSPanoramaView! = nil
    var service = GMSPanoramaService()
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    var myStringData : NSString = ""
    var dataArray : Array<String>!
    var slice : Array<String>!
    var answerLocation : CLLocationCoordinate2D! = nil
    var locationName : String!
    var round = 1
    var points = 0
    @IBOutlet var roundLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //make pano view display
        
        self.panoView = GMSPanoramaView(frame: self.mapArea.frame)
    
        //get a new location
        getNewLocation()

        self.panoView.delegate = self
        panoView.streetNamesHidden = true
        self.mapArea.addSubview(self.panoView)
        bannerView.adUnitID = "ca-app-pub-9488691174829717/4154236789"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        createAndLoadInterstitial()


    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       

    }
    
    func getNewLocation()
    {
        //data scrape from this website
        let url = NSURL(string: "http://www.realestate3d.com/gps/latlong.htm")
        
        
        
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            //if it works, then format the string into a nice, easy, comprehensible string array
            self.myStringData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            let splitted = (self.myStringData as String).components(separatedBy: ["\n"])
            
            let trimmed = splitted.map { String($0).trimmingCharacters(in: .whitespaces) }
            self.slice = Array(trimmed[trimmed.index(of: "Alabama")!..<trimmed.index(of: "</PRE>")!])
            self.slice = self.slice.filter({$0 != ""})
            let sliceString = self.slice[Int(arc4random() % UInt32(self.slice.count))]
            self.recursiveAsync(sliceString: sliceString)
            
        }
        task.resume()
        
        

    }
    
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
        print(error.localizedDescription, coordinate)
    }
    
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama, nearCoordinate coordinate: CLLocationCoordinate2D) {
        print(coordinate)
    }
    
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveToPanoramaID panoramaID: String) {
        print(error.localizedDescription)
    }
    
    //my favorite part of this app: instead of a while loop (which is impossible to do with an async method) I use recursion to loop through and get a random location until it works.
    
    func recursiveAsync(sliceString: String)
    {
    
        self.dataArray = sliceString.components(separatedBy: "  ")
        
        if self.dataArray.count != 1
        {
            self.service.requestPanoramaNearCoordinate(CLLocationCoordinate2D(latitude: (self.dataArray[1] as NSString).doubleValue, longitude: (self.dataArray[2] as NSString).doubleValue * -1), callback: { (pano, error) in
                if error == nil
                {
                    
                    let loc = CLLocationCoordinate2D(latitude: (self.dataArray[1] as NSString).doubleValue, longitude: (self.dataArray[2] as NSString).doubleValue * -1)
                    
                    if (self.answerLocation == nil || (self.answerLocation.latitude != loc.latitude && self.answerLocation.longitude != loc.longitude))
                    {
                        self.panoView.moveNearCoordinate(CLLocationCoordinate2D(latitude: (self.dataArray[1] as NSString).doubleValue, longitude: (self.dataArray[2] as NSString).doubleValue * -1), radius: 100)
                        self.answerLocation = CLLocationCoordinate2D(latitude: (self.dataArray[1] as NSString).doubleValue, longitude: (self.dataArray[2] as NSString).doubleValue * -1)
                        self.locationName = (self.dataArray[3] as NSString) as String!
                    }
                    else
                    {
                         self.recursiveAsync(sliceString: self.slice[Int(arc4random() % UInt32(self.slice.count))])
                    }
                }
                else
                {
                    //if it doesn't work, then do it all over again
                    self.recursiveAsync(sliceString: self.slice[Int(arc4random() % UInt32(self.slice.count))])
                }
            
                })
        }
        else
        {
            //if its not even a lat/long string, then do it all over again
            self.recursiveAsync(sliceString: self.slice[Int(arc4random() % UInt32(self.slice.count))])
        }
        
    }
    
    func newGame()
    {
        performSegue(withIdentifier: "showHighscoreView", sender: self)
        
    }


    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGuessMap"
        {
            dim(direction: .In, alpha: 0.5, speed: dimSpeed)
            let dvc = segue.destination as! PopoverMap
            dvc.senderVC = self
            dvc.answerLocation = self.answerLocation
            dvc.locationName = self.locationName
        }
        
        if segue.identifier == "showHighscoreView"
        {
            dim(direction: .In, alpha: 0.7, speed: dimSpeed)
            let dvc = segue.destination as! PopoverHighscore
            dvc.senderVC = self
            
            
        }
    }
    
    @IBAction func unwindFromSecondary()
    {
        dim(direction: .Out, speed: dimSpeed)
    }
    
    func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9488691174829717/6409699188")
        let request = GADRequest()
         request.testDevices = [ "" ]
        interstitial.load(request)
    }


}

