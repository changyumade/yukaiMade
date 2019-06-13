//
//  MainMenu.swift
//  Gogames
//
//  Created by 張育愷 on 05/06/2019.
//  Copyright © 2019 Andy Chang. All rights reserved.
//

import UIKit

class MainMenu: UIViewController{
    
    var goGameLabel = UILabel()
    var pvcBtn = UIImageView(image: #imageLiteral(resourceName: "offline"))
    var pvpBtn = UIImageView(image: #imageLiteral(resourceName: "online"))
    var backgroundView = UIImageView(image: #imageLiteral(resourceName: "mainbackground"))
    var modeNine = UIButton(type: UIButtonType.system)
    var modeThirteen = UIButton(type: UIButtonType.system)
    var modeNineteen = UIButton(type: UIButtonType.system)
    var backView = UIView()
    let coverView = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(backView)
        backView.addSubview(modeNine)
        backView.addSubview(modeThirteen)
        backView.addSubview(modeNineteen)
        
        backView.addSubview(coverView)
        coverView.addTarget(self, action: #selector(comingSoon), for: .touchUpInside)
        
        modeNine.backgroundColor = UIColor(red: 0xD4/0xFF, green: 0xFF/0xFF, blue: 0xE4/0xFF, alpha: 1)
        modeNine.setBackgroundImage(#imageLiteral(resourceName: "nine"), for: .normal)
        modeNine.tag = 9
        modeNine.addTarget(self, action: #selector(setBoardSize), for: UIControlEvents.touchUpInside)
        modeThirteen.backgroundColor = UIColor(red: 0xD4/0xFF, green: 0xFF/0xFF, blue: 0xE4/0xFF, alpha: 1)
        modeThirteen.setBackgroundImage(#imageLiteral(resourceName: "thirteen"), for: .normal)
        modeThirteen.tag = 13
        modeThirteen.addTarget(self, action: #selector(setBoardSize), for: UIControlEvents.touchUpInside)
        modeNineteen.backgroundColor = UIColor(red: 0xD4/0xFF, green: 0xFF/0xFF, blue: 0xE4/0xFF, alpha: 1)
        modeNineteen.setBackgroundImage(#imageLiteral(resourceName: "nineteen"), for: .normal)
        modeNineteen.tag = 19
        modeNineteen.addTarget(self, action: #selector(setBoardSize), for: UIControlEvents.touchUpInside)
        
        
        
        let tapPVCGesture = UITapGestureRecognizer(target: self, action: #selector(tapPVC(gesture:)))
        pvcBtn.addGestureRecognizer(tapPVCGesture)
        let tapPVPGesture = UITapGestureRecognizer(target: self, action: #selector(tapPVP(gesture:)))
        pvpBtn.addGestureRecognizer(tapPVPGesture)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.contentMode = UIViewContentMode.scaleAspectFill
        self.view.addSubview(backgroundView)
        
        backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        goGameLabel.translatesAutoresizingMaskIntoConstraints = false
        goGameLabel.backgroundColor = UIColor.lightText
        goGameLabel.text = "Normal Go Games"
        goGameLabel.font = UIFont.boldSystemFont(ofSize: 300)
        goGameLabel.textColor = UIColor(red: 0x28/0xFF, green: 0x27/0xFF, blue: 0x28/0xFF, alpha: 1)
        goGameLabel.textAlignment = .center
        goGameLabel.adjustsFontSizeToFitWidth = true
        goGameLabel.minimumScaleFactor = 0.1
        goGameLabel.baselineAdjustment = .alignCenters
        self.view.addSubview(goGameLabel)
        
        goGameLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        goGameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        goGameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        goGameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
        
        pvpBtn.translatesAutoresizingMaskIntoConstraints = false
        pvpBtn.isUserInteractionEnabled = true
        pvpBtn.contentMode = .scaleAspectFit
        pvpBtn.backgroundColor = UIColor(red: 0x5E/0xFF, green: 0xF9/0xFF, blue: 0x87/0xFF, alpha: 1)
        self.view.addSubview(pvpBtn)
        
        pvpBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        pvpBtn.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        pvpBtn.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.33/2).isActive = true
        pvpBtn.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        
        pvcBtn.translatesAutoresizingMaskIntoConstraints = false
        pvcBtn.isUserInteractionEnabled = true
        pvcBtn.contentMode = .scaleAspectFit
        pvcBtn.backgroundColor = UIColor(red: 0x00/0xFF, green: 0xA2/0xFF, blue: 0xFF/0xFF, alpha: 1)
        self.view.addSubview(pvcBtn)

        pvcBtn.bottomAnchor.constraint(equalTo: pvpBtn.topAnchor).isActive = true
        pvcBtn.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        pvcBtn.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.33/2).isActive = true
        pvcBtn.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        
        self.view.bringSubview(toFront: backView)
        self.view.bringSubview(toFront: pvcBtn)
        self.view.bringSubview(toFront: pvpBtn)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backView.frame = CGRect(x: 0, y: 50 + goGameLabel.frame.size.height + pvcBtn.frame.size.height, width: self.view.frame.size.width, height: 0)
        modeNine.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
        modeThirteen.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
        modeNineteen.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
        
        coverView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
    }
    
    @objc func comingSoon(){
        let comingSoonAlert = UIAlertController(title: "COMING SOON!", message: nil, preferredStyle: .alert)
        let okDoNothing = UIAlertAction(title: "ok", style: .default) { (UIAlertAction) in }
        comingSoonAlert.addAction(okDoNothing)
        present(comingSoonAlert,animated: true, completion: nil)
    }
    
    @objc func setBoardSize(sender: UIButton){
        let vc = ViewController()
        vc.numberOfRows = sender.tag
        present(vc, animated: true, completion: nil)
    }
    
    @objc func tapPVC(gesture: UITapGestureRecognizer){
        if modeNine.frame.size.height != 0{
            UIView.animate(withDuration: 0.3, animations: {
                self.backView.frame = CGRect(x: 0, y: 50 + self.goGameLabel.frame.size.height + self.pvcBtn.frame.size.height, width: self.view.frame.size.width, height: 0)
                self.modeNine.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
                self.modeThirteen.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
                self.modeNineteen.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
                
                self.pvpBtn.frame = CGRect(x: 0, y: self.view.frame.size.height - self.pvcBtn.frame.size.height, width: self.view.frame.size.width, height: self.pvcBtn.frame.size.height)
                self.pvcBtn.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50, width: self.view.frame.size.width, height: self.view.frame.size.height / 6)
                
                self.pvpBtn.alpha = 0.7
                self.pvcBtn.alpha = 1
                
                self.coverView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            }, completion: {(finish: Bool) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.backView.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50 + self.view.frame.size.height / 6, width: self.view.frame.size.width, height: self.view.frame.size.height - self.pvcBtn.frame.height * 2 - self.goGameLabel.frame.size.height - 49)
                    self.modeNine.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    self.modeThirteen.frame = CGRect(x: 0, y: self.backView.frame.height / 3, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    self.modeNineteen.frame = CGRect(x: 0, y: self.backView.frame.height / 3 * 2, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                })
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.pvcBtn.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50, width: self.view.frame.size.width, height: self.view.frame.size.height / 6)
                
                self.pvpBtn.alpha = 0.7
                self.pvcBtn.alpha = 1
                
                self.coverView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            }, completion: {(finish: Bool) in
                UIView.animate(withDuration: 0.3, animations: {
//                    self.backView.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50 + self.view.frame.size.height / 6, width: self.view.frame.size.width, height: self.view.frame.size.height - self.pvcBtn.frame.height * 2 - 110)
                    self.backView.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50 + self.view.frame.size.height / 6, width: self.view.frame.size.width, height: self.view.frame.size.height - self.pvcBtn.frame.height * 2 - self.goGameLabel.frame.size.height - 49)
                    self.modeNine.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    self.modeThirteen.frame = CGRect(x: 0, y: self.backView.frame.height / 3, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    self.modeNineteen.frame = CGRect(x: 0, y: self.backView.frame.height / 3 * 2, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                })
            })
        }
    }
    
    @objc func tapPVP(gesture: UITapGestureRecognizer){
        if modeNine.frame.size.height != 0{
            UIView.animate(withDuration: 0.3, animations: {
                self.backView.frame = CGRect(x: 0, y: 50 + self.goGameLabel.frame.size.height + self.pvcBtn.frame.size.height, width: self.view.frame.size.width, height: 0)
                self.modeNine.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
                self.modeThirteen.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
                self.modeNineteen.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
                
                self.pvcBtn.frame = CGRect(x: 0, y: self.view.frame.size.height - self.pvcBtn.frame.size.height, width: self.view.frame.size.width, height: self.pvcBtn.frame.size.height)
                self.pvpBtn.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50, width: self.view.frame.size.width, height: self.view.frame.size.height / 6)
                
                self.pvpBtn.alpha = 1
                self.pvcBtn.alpha = 0.7
            }, completion: {(finish: Bool) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.backView.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50 + self.view.frame.size.height / 6, width: self.view.frame.size.width, height: self.view.frame.size.height - self.pvcBtn.frame.height * 2 - self.goGameLabel.frame.size.height - 49)
                    self.modeNine.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    self.modeThirteen.frame = CGRect(x: 0, y: self.backView.frame.height / 3, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    self.modeNineteen.frame = CGRect(x: 0, y: self.backView.frame.height / 3 * 2, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    
                    self.coverView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.backView.frame.size.height)
                    })
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.pvcBtn.frame = CGRect(x: 0, y: self.pvpBtn.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height / 6)
                self.pvpBtn.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50, width: self.view.frame.size.width, height: self.view.frame.size.height / 6)
                
                self.pvpBtn.alpha = 1
                self.pvcBtn.alpha = 0.7
            }, completion: {(finish: Bool) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.backView.frame = CGRect(x: 0, y: self.goGameLabel.frame.size.height + 50 + self.view.frame.size.height / 6, width: self.view.frame.size.width, height: self.view.frame.size.height - self.pvcBtn.frame.height * 2 - self.goGameLabel.frame.size.height - 49)
                    self.modeNine.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    self.modeThirteen.frame = CGRect(x: 0, y: self.backView.frame.height / 3, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    self.modeNineteen.frame = CGRect(x: 0, y: self.backView.frame.height / 3 * 2, width: self.view.frame.size.width, height: self.backView.frame.height / 3)
                    
                    self.coverView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.backView.frame.size.height)
                    })
            })
        }
    }
}
