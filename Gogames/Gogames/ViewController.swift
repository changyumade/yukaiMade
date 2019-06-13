//
//  ViewController.swift
//  Gogames
//
//  Created by 張育愷 on 23/05/2019.
//  Copyright © 2019 Andy Chang. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass



extension CGPoint: Hashable {
    public var hashValue: Int {
        //This expression can be any of the arbitrary expression which fulfills the axiom above.
        return x.hashValue ^ y.hashValue
    }
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == UIGestureRecognizerState.began {
            return
        }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.began
    }
    
}


class ViewController: UIViewController {
    var backgroundView = UIImageView(image: #imageLiteral(resourceName: "wood"))
    var numberOfRows: Int = 0
    var lastLocation = CGPoint(x: 0, y: 0)
    var isBlack = true
    var state = [CGPoint : Bool]()
    var board:View?
    let groupManager = GroupManager()
    var deadGroups = [String : Group]()
    var stateArray = [[CGPoint : Bool](), [CGPoint : Bool](), [CGPoint : Bool]()]
    var illegalView = UIImageView(image: #imageLiteral(resourceName: "buzzz"))
    var goBackBtn = UIButton(type: UIButtonType.system)
    var passBtn = UIButton(type: UIButtonType.system)
    var freakItOutBtn = UIButton(type: UIButtonType.system)
    var topBarStringLabel = UILabel()
    var numOfPass = 0
    var prepareForCal = false
    var markerPool = [String : Dictionary <CGPoint, CALayer>]()
    var emptySpots = [CGPoint : String]()
    var isBlackField = false
    var isWhiteField = false
    var undefinedField = [CGPoint : String]()
    let quotations = ["在非洲過了60秒, 在這裡等於過了一分鐘", "每天省下一杯奶茶的錢, 十天後就可以買十杯奶茶", "當你在睡覺時, 美國人正在辛勤工作"]
    let selfImagePool = [#imageLiteral(resourceName: "selfimage1"), #imageLiteral(resourceName: "selfimage2"), #imageLiteral(resourceName: "selfimage3")]
    var selfADLable = UILabel()
    var selfImage = UIImageView(image: #imageLiteral(resourceName: "selfimage1"))
    var secondSelfADLable = UILabel()
    var secondSelfImage = UIImageView()
    var timer = Timer()
    var winner = ""
    let endView = UILabel()
    let okBtn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        board = View(numberOfRows: numberOfRows, frame: self.view.frame)
        if let board = board {
            let panGesture = InstantPanGestureRecognizer(target: self, action: #selector(detectPan(gesture:)))
            board.isUserInteractionEnabled = true
            board.addGestureRecognizer(panGesture)
            self.view.addSubview(board)
            
            board.translatesAutoresizingMaskIntoConstraints = false
            board.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            board.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            board.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier:0.9).isActive = true
            board.heightAnchor.constraint(equalTo: board.widthAnchor).isActive = true
        }
        self.view.addSubview(topBarStringLabel)
        self.view.addSubview(passBtn)
        self.view.addSubview(goBackBtn)
        self.view.addSubview(freakItOutBtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topBarStringLabel.text = quotations[Int(arc4random_uniform(3))]
        topBarStringLabel.textAlignment = .center
        topBarStringLabel.textColor = UIColor.darkGray
        topBarStringLabel.layer.borderWidth = 3
        topBarStringLabel.layer.borderColor = UIColor.darkGray.cgColor
        topBarStringLabel.shadowColor = UIColor.black
        topBarStringLabel.shadowOffset = CGSize(width: 0, height: 1)
        topBarStringLabel.frame = CGRect(x: 10, y: 15, width: self.view.frame.size.width - 20, height: (self.board?.frame.origin.y)! / 2 - 25)
        
        goBackBtn.setBackgroundImage(#imageLiteral(resourceName: "btn3"), for: .normal)
        goBackBtn.setTitle("Back", for: .normal)
        goBackBtn.setTitleColor(UIColor.black, for: .normal)
        goBackBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        goBackBtn.tag = 1
        goBackBtn.addTarget(self, action: #selector(tapBtn(sender:)), for: UIControlEvents.touchUpInside)
        goBackBtn.frame = CGRect(x: 0, y: (self.board?.frame.origin.y)! / 2, width: self.view.frame.size.width / 3, height: (self.board?.frame.origin.y)! / 2 - 10)
        
        freakItOutBtn.setBackgroundImage(#imageLiteral(resourceName: "btn2"), for: .normal)
        freakItOutBtn.setTitle("Boom", for: .normal)
        freakItOutBtn.setTitleColor(UIColor.black, for: .normal)
        freakItOutBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        freakItOutBtn.tag = 2
        freakItOutBtn.addTarget(self, action: #selector(tapBtn(sender:)), for: UIControlEvents.touchUpInside)
        freakItOutBtn.frame = CGRect(x: self.view.frame.size.width / 3, y: (self.board?.frame.origin.y)! / 2, width: self.view.frame.size.width / 3, height: (self.board?.frame.origin.y)! / 2 - 10)

        passBtn.setBackgroundImage(#imageLiteral(resourceName: "btn1"), for: .normal)
        passBtn.setTitle("Pass", for: .normal)
        passBtn.setTitleColor(UIColor.black, for: .normal)
        passBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        passBtn.tag = 3
        passBtn.addTarget(self, action: #selector(tapBtn(sender:)), for: UIControlEvents.touchUpInside)
        passBtn.frame = CGRect(x: self.view.frame.width / 3 * 2, y: (self.board?.frame.origin.y)! / 2, width: self.view.frame.size.width / 3, height: (self.board?.frame.origin.y)! / 2 - 10)
        
        self.view.addSubview(selfImage)
        selfImage.backgroundColor = UIColor.black
        selfImage.contentMode = .scaleAspectFit
        selfImage.frame = CGRect(x: 0, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3, height: 0)
        
        self.view.addSubview(selfADLable)
        selfADLable.backgroundColor = UIColor.black
        selfADLable.frame = CGRect(x: selfImage.frame.size.width, y: selfImage.frame.origin.y + 10, width: selfImage.frame.size.width * 2, height: 0)
        selfADLable.numberOfLines = 0
        selfADLable.text = " 張育愷, Andy Chang\n Junior ios developer,\n ex-IE engineer\n 熟悉Swift, 具備Auto Layout, 串接\n RESTful API經驗"
        selfADLable.textColor = UIColor.white
        
        self.view.addSubview(secondSelfImage)
        secondSelfImage.backgroundColor = UIColor.black
        secondSelfImage.contentMode = .scaleAspectFit
        secondSelfImage.frame = CGRect(x: 0, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3, height: 0)
        
        self.view.addSubview(secondSelfADLable)
        secondSelfADLable.backgroundColor = UIColor.black
        secondSelfADLable.frame = CGRect(x: selfImage.frame.size.width, y: selfImage.frame.origin.y + 10, width: selfImage.frame.size.width * 2, height: 0)
        secondSelfADLable.numberOfLines = 0
        secondSelfADLable.text = " Contact Me: \n 0927-683-989\n yukai77788@gmail.com\n 彰化縣二林鎮東興里平等街55號"
        secondSelfADLable.textColor = UIColor.white
        
        UIView.animate(withDuration: 0.3, animations: {
            self.selfADLable.frame = CGRect(x: self.selfImage.frame.size.width, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3 * 2, height: (self.board?.frame.origin.y)! - 10)
            self.selfImage.frame = CGRect(x: 0, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3, height: (self.board?.frame.origin.y)! - 10)
        })
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (Timer) in
            self.selfImage.image = self.selfImagePool[Int(arc4random_uniform(3))]
            self.secondSelfImage.image = self.selfImagePool[Int(arc4random_uniform(3))]
            if self.selfADLable.frame.size.height != 0{
                UIView.animate(withDuration: 0.3, animations: {
                    self.selfADLable.frame = CGRect(x: self.selfImage.frame.size.width, y: self.selfImage.frame.origin.y + 10, width: self.selfImage.frame.size.width * 2, height: 0)
                    self.secondSelfADLable.frame = CGRect(x: self.selfImage.frame.size.width, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3 * 2, height: (self.board?.frame.origin.y)! - 10)
                    self.selfImage.frame = CGRect(x: 0, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3, height: 0)
                    self.secondSelfImage.frame = CGRect(x: 0, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3, height: (self.board?.frame.origin.y)! - 10)
                })
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.selfADLable.frame = CGRect(x: self.selfImage.frame.size.width, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3 * 2, height: (self.board?.frame.origin.y)! - 10)
                    self.secondSelfADLable.frame = CGRect(x: self.selfImage.frame.size.width, y: self.selfImage.frame.origin.y + 10, width: self.selfImage.frame.size.width * 2, height: 0)
                    self.selfImage.frame = CGRect(x: 0, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3, height: (self.board?.frame.origin.y)! - 10)
                    self.secondSelfImage.frame = CGRect(x: 0, y: self.view.frame.size.height - (self.board?.frame.origin.y)! + 10, width: self.view.frame.size.width / 3, height: 0)
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    func changeGoColor(){
        if isBlack{
            isBlack = false
        }else{
            isBlack = true
        }
    }
    
    func illegal(){
        self.view.addSubview(illegalView)
        illegalView.contentMode = UIViewContentMode.scaleAspectFit
        illegalView.translatesAutoresizingMaskIntoConstraints = false
        illegalView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        illegalView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        illegalView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        illegalView.heightAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
            self.illegalView.removeFromSuperview()
            })
    }
    
    @objc func tapBtn(sender: UIButton){
        if sender.tag == 1{
            dismiss(animated: true, completion: nil)
        }
        else if sender.tag == 2{
            let freakImage = UIImageView(image: #imageLiteral(resourceName: "pikachiuface"))
            freakImage.contentMode = UIViewContentMode.scaleAspectFit
            self.view.addSubview(freakImage)
            freakImage.frame = CGRect(x: self.view.frame.size.width / 2 - 0.5, y: self.view.frame.size.height / 2 - 0.5, width: 1, height: 1)
            UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 0.1, initialSpringVelocity: 3, animations: {
                freakImage.transform = CGAffineTransform(scaleX: self.view.frame.size.width, y: self.view.frame.size.width)
            })
            _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (Timer) in
                freakImage.removeFromSuperview()
                })
        }
        else if sender.tag == 3{
            numOfPass += 1
            changeGoColor()
            let passImage = UIImageView(image: #imageLiteral(resourceName: "pass"))
            self.view.addSubview(passImage)
            passImage.translatesAutoresizingMaskIntoConstraints = false
            passImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            passImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            passImage.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            passImage.heightAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
                passImage.removeFromSuperview()
                })
            if numOfPass == 2{
                numOfPass = 0
                prepareForCal = true
                
                selfImage.removeFromSuperview()
                secondSelfImage.removeFromSuperview()
                selfADLable.removeFromSuperview()
                secondSelfADLable.removeFromSuperview()
                timer.invalidate()
                
                let confirmBtn = UIButton(type: UIButtonType.system)
                confirmBtn.translatesAutoresizingMaskIntoConstraints = false
                confirmBtn.addTarget(self, action: #selector(findWinner), for: UIControlEvents.touchUpInside)
                confirmBtn.setBackgroundImage(#imageLiteral(resourceName: "confirmBtn"), for: .normal)
                confirmBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
                self.view.addSubview(confirmBtn)
                confirmBtn.topAnchor.constraint(equalTo: (self.board?.bottomAnchor)!, constant: 20).isActive = true
                confirmBtn.rightAnchor.constraint(equalTo: (self.board?.rightAnchor)!).isActive = true
                confirmBtn.leftAnchor.constraint(equalTo: (self.board?.leftAnchor)!).isActive = true
                confirmBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
            }
        }
    }
    
    @objc func backToMainMenu(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func findWinner(){
        var allSpots = [CGPoint]()
        var spotX = 0
        var spotY = 0
        var blackLand = [CGPoint]()
        var whiteLand = [CGPoint]()
        
        for (_, markers) in markerPool{
            for (spot, marker) in markers{
                marker.removeFromSuperlayer()
                state[spot] = nil
            }
        }
        board?.update(state: state)
        
        for _ in 0...numberOfRows * numberOfRows - 1{
            allSpots.append(CGPoint(x: spotX, y: spotY))
            spotX += 1
            if spotX == numberOfRows{
                spotX = 0
                spotY += 1
            }
        }
        for spot in allSpots{
            if state[spot] == nil{
                emptySpots[spot] = ""
            }
        }
        repeat{
            var emptySpotPool = Array(emptySpots.keys)
            generateChildSpots(spot: emptySpotPool[0])
            if isBlackField && isWhiteField{
                // undefined
            }else if isBlackField{
                for (spot, _) in undefinedField{
                    blackLand.append(spot)
                }
            }else if isWhiteField{
                for (spot, _) in undefinedField{
                    whiteLand.append(spot)
                }
            }
            undefinedField.removeAll()
            isBlackField = false
            isWhiteField = false
        }while(emptySpots.count > 0)
        
        for (position, isBlack) in state{
            if isBlack{
                blackLand.append(position)
            }else{
                whiteLand.append(position)
            }
        }
        
        if numberOfRows == 19{
            if blackLand.count - whiteLand.count > 3{
                // black win
                winner = "black"
            }else{
                // white win
                winner = "white"
            }
        }else if numberOfRows == 13{
            if blackLand.count - whiteLand.count > 3{
                // black win
                winner = "black"
            }else{
                // white win
                winner = "white"
            }
        }else if numberOfRows == 9{
            if blackLand.count - whiteLand.count > 3{
                // black win
                winner = "black"
            }else{
                // white win
                winner = "white"
            }
        }
        
        self.view.addSubview(endView)
        self.view.bringSubview(toFront: endView)
        endView.backgroundColor = UIColor.white
        endView.alpha = 0.9
        endView.textAlignment = .center
        endView.font = UIFont.boldSystemFont(ofSize: 20)
        endView.numberOfLines = 0
        endView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        if winner == "black"{
            endView.text = "BLACK WIN!\n(win by \(Double(blackLand.count - whiteLand.count) - 3.5))\n\nBlack: \(blackLand.count) moyo\n\nWhite: \(whiteLand.count) moyo\n\n\n"
        }else if winner == "white"{
            endView.text = "WHITE WIN!\n(win by \(Double(whiteLand.count - blackLand.count) - 3.5))\n\nBlack: \(blackLand.count) moyo\n\nWhite: \(whiteLand.count) moyo\n\n\n"
        }
        
        okBtn.addTarget(self, action: #selector(backToMainMenu), for: .touchUpInside)
        okBtn.setTitle("Click to continue", for: .normal)
        okBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        self.view.addSubview(okBtn)
        
        okBtn.translatesAutoresizingMaskIntoConstraints = false
        okBtn.bottomAnchor.constraint(equalTo: endView.bottomAnchor, constant: -50).isActive = true
        okBtn.leftAnchor.constraint(equalTo: endView.leftAnchor).isActive = true
        okBtn.rightAnchor.constraint(equalTo: endView.rightAnchor).isActive = true
        okBtn.heightAnchor.constraint(equalTo: endView.heightAnchor, multiplier: 0.25).isActive = true
    }
    
    func generateChildSpots(spot: CGPoint){
        var temp = [CGPoint]()
        
        if state[spot] == true{
            // black code
            isBlackField = true
            return
        }else if state[spot] == false{
            // white code
            isWhiteField = true
            return
        }else if emptySpots[spot] == nil{
            return
        }
        
        undefinedField[spot] = ""
        emptySpots[spot] = nil
        
        temp.append(CGPoint(x: spot.x + 1, y: spot.y))
        temp.append(CGPoint(x: spot.x - 1, y: spot.y))
        temp.append(CGPoint(x: spot.x, y: spot.y + 1))
        temp.append(CGPoint(x: spot.x, y: spot.y - 1))
            
        for tempSpot in temp{
            if tempSpot.x >= 0 && tempSpot.x < CGFloat(numberOfRows) && tempSpot.y >= 0 && tempSpot.y < CGFloat(numberOfRows){
                generateChildSpots(spot: tempSpot)
            }
        }
    }
    
    
    @objc func detectPan(gesture: InstantPanGestureRecognizer){
        var isLegal = true
        let location = gesture.location(in: board)

        if let boardPosition = board?.getBoardPosition(location: location){
            if gesture.state == UIGestureRecognizerState.began ||
                gesture.state == UIGestureRecognizerState.changed ||
                gesture.state == UIGestureRecognizerState.possible {
                
                board?.drawRedLine(boardPosition: boardPosition)
                
            }else if gesture.state == UIGestureRecognizerState.ended{
                if !prepareForCal{
                    if let currentGroup = groupManager.checkPointEmpty(numberOfRows: numberOfRows, boardPosition: boardPosition, isBlack: isBlack){
                        let dyingGroup = groupManager.checkIsKillable(killer: currentGroup)
                        
                        if dyingGroup.count > 0{
                            if !groupManager.checkKO(killer: currentGroup){
                                groupManager.invalidBreath(currentGroup: currentGroup)
                                state = groupManager.killThenMerge(killer: currentGroup)
                            }else{
                                illegal()
                                isLegal = false
                            }
                        }else{
                            if !groupManager.checkSuicide(currentGroup: currentGroup){
                                groupManager.invalidBreath(currentGroup: currentGroup)
                                state = groupManager.mergeGroup(currentGroup: currentGroup)
                            }else{
                                // suicide return error
                                illegal()
                                isLegal = false
                            }
                        }
                    }else{
                        // is occupied
                        illegal()
                        isLegal = false
                    }
                    if isLegal{
                        changeGoColor()
                    }
                    board?.update(state: state)
                    board?.removeRedLine()
                
                    stateArray.insert(state, at: 0)
                    if stateArray.count > 3{
                        stateArray.remove(at: 3)
                    }
                }else{
                    var needDrawing = true
                    var selectedGroup = groupManager.findSelectedGroup(boardPosition: boardPosition)
                    if selectedGroup.count > 0{
                        if markerPool.count == 0{
                            if let isBlack = state[selectedGroup[0]]{
                                for spot in selectedGroup{
                                    board?.drawMarker(boardPosition: spot, isBlack: isBlack)
                                }
                                if let selectedMarker = board?.selectedMarker{
                                    let timestamp = Date().timeIntervalSince1970.description
                                    markerPool[timestamp] = selectedMarker
                                }
                                board?.selectedMarker.removeAll()
                            }
                        }else{
                            for (id, markers) in markerPool{
                                if markers[boardPosition] != nil{
                                    for (_, marker) in markers{
                                        marker.removeFromSuperlayer()
                                    }
                                    markerPool[id] = nil
                                    needDrawing = false
                                }
                                if needDrawing{
                                    if let isBlack = state[selectedGroup[0]]{
                                        for spot in selectedGroup{
                                            board?.drawMarker(boardPosition: spot, isBlack: isBlack)
                                        }
                                        if let selectedMarker = board?.selectedMarker{
                                            let timestamp = Date().timeIntervalSince1970.description
                                            markerPool[timestamp] = selectedMarker
                                        }
                                    }
                                    board?.selectedMarker.removeAll()
                                }
                            }
                        }
                    }
                    board?.removeRedLine()
                }
            } else {
                board?.removeRedLine()
            }
        }
    }
}

