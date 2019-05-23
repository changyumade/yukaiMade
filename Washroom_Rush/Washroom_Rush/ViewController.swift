//
//  ViewController.swift
//  Washroom_Rush
//
//  Created by 張育愷 on 07/05/2019.
//  Copyright © 2019 Andy Chang. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import Alamofire
import Foundation
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, XMLParserDelegate, GMSMapViewDelegate {
    
    var myLat : Double?
    var myLon : Double?
    var saveToToiletData : Bool?
    var toiletKey : String?
    var toiletData = [String : String]()
    var toilets = [Int: Dictionary <String, String>]()
    var desireLat: Double?
    var desireLon: Double?
    var isAfterTapping: Bool = false
    var alreadyGetToilets:Bool = false
    var toiletName: String?
    let locationManager = CLLocationManager()
    var sosData = [String: Double]()
    var currentTimestamp: Double?
    var timer = Timer()
    var viewAllButton: UIButton?
    var markerpool = [String : GMSMarker]()
    var nearestMarker: GMSMarker?
    var alreadyFindGPS = false
    var unusedPolyLine = [GMSPolyline]()
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set GMSMapview delegate as self, in order to use didTap func..
        googleMapView.delegate = self
        
        // Get self current location...
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // init button..
        viewAllButton = UIButton(type: .system)
        viewAllButton?.frame = CGRect(x: self.view.frame.size.width - 100 - 20, y: self.view.frame.size.height - 50 - 20, width: 100, height: 50)
        viewAllButton?.setTitle("View All", for: .normal)
        viewAllButton?.setTitleColor(UIColor.black, for: .normal)
        viewAllButton?.setBackgroundImage(#imageLiteral(resourceName: "viewallButton"), for: .normal)
        viewAllButton?.addTarget(self, action: #selector(self.tappingViewAll), for: .touchUpInside)
        
        getCurrentTimestamp()
        getSOSData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateSOS), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        alreadyFindGPS = true
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            myLat = location.coordinate.latitude
            myLon = location.coordinate.longitude
            
            // Set GoogleMap camera..
            let camera = GMSCameraPosition.camera(withLatitude: myLat!, longitude: myLon!, zoom: 18)
            googleMapView.camera = camera
            googleMapView.isMyLocationEnabled = true
            toiletDataGetting()
        }else{
            print("Can't find current location!")
        }
    }
    
    func toiletDataGetting(){
        Alamofire.request("http://www.dep-in.gov.taipei/epb/webservice/toilet.asmx/GetToiletData", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).response(completionHandler: { response in
            if response.data != nil{
                let parser = XMLParser(data: response.data!)
                parser.delegate = self
                parser.parse()
            }else{
                print("Can't get toilet data!")
            }
        })
    }
    
    // using XML parser and creating array to keep data..
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName != "ToiletData" && elementName != "ArrayOfToiletData"{
            saveToToiletData = true
            toiletKey = elementName
        }else{
            
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if saveToToiletData == true{
            toiletData[toiletKey!] = string
            saveToToiletData = false
        }else{
            
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "ToiletData"{
            toilets[toilets.count] = toiletData
            toiletData = [String : String]()
        }else{
            
        }
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        recordMarker()
        
        if isAfterTapping == false{
            findClosestSpot()
        }else{
            findAllSpot()
        }
        alreadyGetToilets = true
    }
    
    func drawingPath(origin: String, destination: String){
        Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&key=AIzaSyDRGfa9kbJilkMOFq1moSmbnnfBCkSwb-w", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {response in
            let json : JSON = try! JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            for route in routes{
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline!["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.blue
                polyline.map = self.googleMapView
                
                self.unusedPolyLine.append(polyline)
            }
        })
        print("https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&key=AIzaSyDRGfa9kbJilkMOFq1moSmbnnfBCkSwb-w")
    }
    
    @objc func tappingViewAll(){
        googleMapView.clear()
        if isAfterTapping == false{
            isAfterTapping = true
            findAllSpot()
        }else{
            isAfterTapping = false
            findClosestSpot()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let destinationLat: Double = marker.position.latitude
        let destinationLon: Double = marker.position.longitude
        
        unusedPolyLine[unusedPolyLine.count - 1].map = nil
        
        for (key, value) in toilets{
            if destinationLat == Double(value["Lat"] as! String) && destinationLon == Double(value["Lng"] as! String){
                toiletName = value["DepName"] as! String
            }else{
                
            }
        }
        
        drawingPath(origin: "\(myLat!),\(myLon!)", destination: "\(destinationLat),\(destinationLon)")
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = UIView()
        let infoLabel = UILabel()
        let goToComment = UILabel()
        let nextImage = UIImageView(image: #imageLiteral(resourceName: "nextArrow"))
        let infoWindowSize = CGSize(width: 200, height: 100)
        
        infoWindow.addSubview(infoLabel)
        infoWindow.addSubview(goToComment)
        infoWindow.addSubview(nextImage)
        
        infoWindow.frame = CGRect(origin: marker.infoWindowAnchor, size: infoWindowSize)
        infoWindow.layer.cornerRadius = 5
        infoWindow.layer.masksToBounds = true
        infoWindow.backgroundColor = UIColor.white
        infoWindow.layer.borderColor = UIColor.black.cgColor
        infoWindow.layer.borderWidth = 1
        
        infoLabel.frame = CGRect(x: 10, y: 10, width: 180, height: 30)
        infoLabel.text = toiletName
        goToComment.frame = CGRect(x: 10, y: 50, width: 180, height: 40)
        goToComment.text = " Tap to comment!"
        goToComment.backgroundColor = UIColor.init(red: CGFloat(0xDD/0xFF), green: CGFloat(0xDD/0xFF), blue: CGFloat(0xDD/0xFF), alpha: 0.1)
        nextImage.frame = CGRect(x: 150, y: 50, width: 40, height: 40)
        
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let vc = CommentViewController()
        vc.toiletName = toiletName!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getSOSData(){
        Alamofire.request("http://localhost:3030/getsos", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).response(completionHandler: { response in
            if response.data != nil{
                print("sos sucess")
                var sosjson: JSON
                do{
                    sosjson = try JSON(data: response.data!)
                }catch{
                    sosjson = JSON([Dictionary<String, Double>]())
                    print(error.localizedDescription)
                }
                for dic in sosjson.array!{
                    self.sosData[dic["toilet_name"].stringValue] = dic["time"].doubleValue
                    print(dic["time"].doubleValue)
                }
            }else{
                print("no sos data")
            }
        })
    }
    
    func getCurrentTimestamp(){
        let date = Date()
        currentTimestamp = date.timeIntervalSince1970
    }
    
    func findClosestSpot(){
        // init closestSpotButton to viewAllButoon..
        viewAllButton?.setTitle("View All", for: .normal)
        
        var desireSpot: Double = 9000
        var nearestToilet: String?

        for (key, value) in markerpool{
            var distance: Double = (myLat! - value.position.latitude) * (myLat! - value.position.latitude) + (myLon! - value.position.longitude) * (myLon! - value.position.longitude)
            if distance < desireSpot{
                desireSpot = distance
                nearestToilet = key
            }else{
                
            }
        }
        for (key, value) in sosData{
            if key == nearestToilet! && currentTimestamp! - value <= 600{
                markerpool[nearestToilet!]?.iconView = UIImageView(image: #imageLiteral(resourceName: "sosMarker"))
                markerpool[nearestToilet!]?.iconView?.frame.size = CGSize(width: 50, height: 50)
            }
        }
        markerpool[nearestToilet!]?.map = googleMapView
        let closestSpotLat: String = String(markerpool[nearestToilet!]?.position.latitude as! Double)
        let closestSpotLon: String = String(markerpool[nearestToilet!]?.position.longitude as! Double)
        print(closestSpotLat)
        print(closestSpotLon)
        
        drawingPath(origin: "\(myLat!),\(myLon!)", destination: "\(closestSpotLat),\(closestSpotLon)")
        self.view.addSubview(viewAllButton!)
        nearestMarker = markerpool[nearestToilet!]
        nearestMarker?.title = nearestToilet!
    }
    
    func findAllSpot(){
        for (markerKey, markerValue) in markerpool{
            for (sosKey, sosValue) in sosData{
                if sosKey == markerKey && currentTimestamp! - sosData[sosKey]! <= 600{
                    markerValue.iconView = UIImageView(image: #imageLiteral(resourceName: "sosMarker"))
                    markerValue.iconView?.frame.size = CGSize(width: 50, height: 50)
                }
            }
            markerValue.map = googleMapView
        }
        // init viewAllButton to closestSpotButton..
        viewAllButton?.setTitle("Closest Spot", for: .normal)
    }
    
    @objc func updateSOS(){
        if alreadyFindGPS == true{
            if alreadyGetToilets == true{
                getCurrentTimestamp()
                if isAfterTapping == false{
                    getSOSData()
                    for (key, value) in sosData{
                        if key == (nearestMarker?.title)! && currentTimestamp! - value <= 600{
                            nearestMarker?.iconView = UIImageView(image: #imageLiteral(resourceName: "sosMarker"))
                            nearestMarker?.iconView?.frame.size = CGSize(width: 50, height: 50)
                        }else if key == (nearestMarker?.title)! && currentTimestamp! - value > 600{
                            nearestMarker?.iconView = nil
                        }
                    }
                }else{
                    getSOSData()
                    for (markerKey, markerValue) in markerpool{
                        for (sosKey, sosValue) in sosData{
                            if markerKey == sosKey && currentTimestamp! - sosValue <= 600{
                                markerValue.iconView = UIImageView(image: #imageLiteral(resourceName: "sosMarker"))
                                markerValue.iconView?.frame.size = CGSize(width: 50, height: 50)
                            }else if markerKey == sosKey && currentTimestamp! - sosValue > 600{
                                markerValue.iconView = nil
                            }
                        }
                    }
                }
            }else{
                updateSOS()
            }
        }else{
            
        }
    }
    
    func recordMarker(){
        for (key, value) in toilets{
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(Double(value["Lat"]!)!, Double(value["Lng"]!)!)
            markerpool[value["DepName"]!] = marker
            
        }
    }
    
}
