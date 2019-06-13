//
//  View.swift
//  Gogames
//
//  Created by 張育愷 on 28/05/2019.
//  Copyright © 2019 Andy Chang. All rights reserved.
//

import Foundation
import UIKit

class View: UIView{
    
    let axisY = UIView()
    let axisX = UIView()
    var gridLength: CGFloat = 0
    var eachLineSpot = [CGFloat]()
    var goStadium = UIView()
    var goArray = [CALayer]()
    var numberOfRows: Int = 0
    var state = [CGPoint:Bool]()
    var selectedMarker = [CGPoint : CALayer]()
    
    init(numberOfRows: Int, frame: CGRect) {
        super.init(frame: frame)
        self.numberOfRows = numberOfRows
        self.addSubview(axisX)
        self.addSubview(axisY)
        axisX.backgroundColor = UIColor.red
        axisY.backgroundColor = UIColor.red
        axisX.isHidden = true
        axisY.isHidden = true
    }
    
    override func layoutSubviews() {
        goStadium.removeFromSuperview()
        goStadium = UIView()

        gridLength = (self.frame.size.width - 20) / CGFloat(numberOfRows - 1)
        
        let dotFor9 = [
            CGPoint(x: 10 + gridLength * 2, y: 10 + gridLength * 2),
            CGPoint(x: 10 + gridLength * 6, y: 10 + gridLength * 2),
            CGPoint(x: 10 + gridLength * 2, y: 10 + gridLength * 6),
            CGPoint(x: 10 + gridLength * 6, y: 10 + gridLength * 6),
            CGPoint(x: 10 + gridLength * 4, y: 10 + gridLength * 4)
        ]
        let dotFor13 = [
            CGPoint(x: 10 + gridLength * 3, y: 10 + gridLength * 3),
            CGPoint(x: 10 + gridLength * 9, y: 10 + gridLength * 3),
            CGPoint(x: 10 + gridLength * 3, y: 10 + gridLength * 9),
            CGPoint(x: 10 + gridLength * 9, y: 10 + gridLength * 9),
            CGPoint(x: 10 + gridLength * 6, y: 10 + gridLength * 6)
        ]
        let dotFor19 = [
            CGPoint(x: 10 + gridLength * 3, y: 10 + gridLength * 3),
            CGPoint(x: 10 + gridLength * 3, y: 10 + gridLength * 9),
            CGPoint(x: 10 + gridLength * 3, y: 10 + gridLength * 15),
            CGPoint(x: 10 + gridLength * 9, y: 10 + gridLength * 3),
            CGPoint(x: 10 + gridLength * 9, y: 10 + gridLength * 9),
            CGPoint(x: 10 + gridLength * 9, y: 10 + gridLength * 15),
            CGPoint(x: 10 + gridLength * 15, y: 10 + gridLength * 3),
            CGPoint(x: 10 + gridLength * 15, y: 10 + gridLength * 9),
            CGPoint(x: 10 + gridLength * 15, y: 10 + gridLength * 15)
        ]
        
        let dot = [9 : dotFor9, 13 : dotFor13, 19 : dotFor19]
        
        for i in 0...numberOfRows - 1{
            eachLineSpot.append(gridLength * CGFloat(i) + 10)
        }
        
        drawBoard()
        
        for spot in eachLineSpot{
            drawLine(onLayer: goStadium.layer, fromPoint: CGPoint(x: 10, y: spot), toPoint: CGPoint(x: self.frame.size.width - 10, y: spot))
            drawLine(onLayer: goStadium.layer, fromPoint: CGPoint(x: spot, y: 10), toPoint: CGPoint(x: spot, y: self.frame.size.width - 10))
        }
        
        for spot in dot[numberOfRows]!{
            drawDot(onLayer: goStadium.layer, position: spot)
        }
        
        self.update(state: self.state)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawBoard(){
        self.insertSubview(goStadium, at: 0)
        goStadium.translatesAutoresizingMaskIntoConstraints = false

        goStadium.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        goStadium.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        goStadium.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        goStadium.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func drawLine(onLayer layer: CALayer, fromPoint start: CGPoint, toPoint end: CGPoint) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = nil
        line.opacity = 1.0
        line.strokeColor = UIColor.black.cgColor
        layer.addSublayer(line)
    }
    
    func drawDot(onLayer layer: CALayer, position: CGPoint){
        let dot = CALayer()
        let dotRadius = gridLength/10
        dot.frame = CGRect(x: position.x - dotRadius, y: position.y - dotRadius, width: dotRadius*2, height: dotRadius*2)
        dot.cornerRadius = dotRadius
        dot.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(dot)
    }
    
    func drawGo (onLayer layer: CALayer, boardPosition: CGPoint, odd: Bool){
        let go = CALayer()
        let position = CGPoint(x: boardPosition.x * gridLength + 10, y: boardPosition.y * gridLength + 10)
        go.frame = CGRect(x: position.x - gridLength / 2 + 2.5, y: position.y - gridLength / 2 + 2.5, width: gridLength - 5, height: gridLength - 5)
        go.cornerRadius = gridLength / 2 - 2.5
        if odd == true{
            go.backgroundColor = UIColor.black.cgColor
        }else{
            go.backgroundColor = UIColor.white.cgColor
        }
        layer.addSublayer(go)
        goArray.append(go)
    }
    
    func drawMarker(boardPosition: CGPoint, isBlack: Bool){
        let marker = CALayer()
        let position = CGPoint(x: boardPosition.x * gridLength + 10, y: boardPosition.y * gridLength + 10)
        marker.frame = CGRect(x: position.x - gridLength / 6, y: position.y - gridLength / 6, width: gridLength / 3, height: gridLength / 3)
        if isBlack{
            marker.backgroundColor = UIColor.white.cgColor
        }else{
            marker.backgroundColor = UIColor.black.cgColor
        }
        layer.addSublayer(marker)
        self.selectedMarker[boardPosition] = marker
    }
    
    func update(state: Dictionary <CGPoint, Bool>){
        for layer in goArray {
            layer.removeFromSuperlayer()
        }
        goArray.removeAll()
        for (position, type) in state {
            self.drawGo(onLayer: self.goStadium.layer, boardPosition: position, odd: type)
        }
        self.state = state
    }
    
    func getBoardPosition(location: CGPoint)->CGPoint{
        let boardPosition = CGPoint(x: lround(Double((location.x - 10) / gridLength)), y: lround(Double((location.y - 10) / gridLength)))
        return boardPosition
    }
    
    func drawRedLine(boardPosition: CGPoint){
        
        let position = CGPoint(x: boardPosition.x * gridLength + 10 - 1.5, y: boardPosition.y * gridLength + 10 - 1.5)
        
        
        axisX.frame = CGRect(x: 0, y: position.y, width: self.frame.size.width, height: 3)
        axisY.frame = CGRect(x: position.x, y: 0, width: 3, height: self.frame.size.width)
        
        axisX.isHidden = false
        axisY.isHidden = false
    }
    
    func removeRedLine(){
        axisX.isHidden = true
        axisY.isHidden = true
    }
    
}
