//
//  GroupManager.swift
//  Gogames
//
//  Created by 張育愷 on 28/05/2019.
//  Copyright © 2019 Andy Chang. All rights reserved.
//

import Foundation
import UIKit

class Group{
    var position = [CGPoint : String]()
    var breath = [CGPoint : Bool]()
    var id: String = ""
    var isBlack = true
    var killerPosition = CGPoint(x: 0, y: 0)
    
    func changeColor(){
        if isBlack{
            isBlack = false
        }else{
            isBlack = true
        }
    }
    func isOverlapped(group: Group){
        
    }
}

class GroupManager{
    
    var state = [CGPoint : Bool]()
    var simulateState = [CGPoint : Bool]()
    var stateRecord = [Dictionary <CGPoint, Bool>]()
    var blackGroups = [String : Group]()
    var whiteGroups = [String : Group]()
    
    func checkPointEmpty(numberOfRows: Int, boardPosition: CGPoint, isBlack: Bool)->Group?{
        let currentGroup = Group()
        currentGroup.isBlack = isBlack
        if state[boardPosition] != nil{
            return nil
        }else{
            currentGroup.id = Date().timeIntervalSince1970.description
            currentGroup.position[boardPosition] = ""
            currentGroup.breath[CGPoint(x: boardPosition.x + 1, y: boardPosition.y)] = true
            currentGroup.breath[CGPoint(x: boardPosition.x - 1, y: boardPosition.y)] = true
            currentGroup.breath[CGPoint(x: boardPosition.x, y: boardPosition.y + 1)] = true
            currentGroup.breath[CGPoint(x: boardPosition.x, y: boardPosition.y - 1)] = true
            for (breath, _) in currentGroup.breath{
                if breath.x > CGFloat(numberOfRows - 1) || breath.x < 0 || breath.y > CGFloat(numberOfRows - 1) || breath.y < 0 || state[breath] != nil{
                    currentGroup.breath[breath] = false
                }
            }
        }
        currentGroup.killerPosition = Array(currentGroup.position.keys)[0]
        return currentGroup
    }
    
    func checkIsKillable(killer: Group)->Dictionary <String, Group>{
        var dyingGroups = [String : Group]()
        var groupIsAlive = [Bool]()
        
        if killer.isBlack{
            for (id, group) in whiteGroups{
                groupIsAlive.removeAll()
                if group.breath[killer.killerPosition] != nil{
                    for (breath, isValid) in group.breath{
                        if breath == killer.killerPosition{
                            continue
                        }
                        if isValid{
                            groupIsAlive.insert(true, at: 0)
                        }else{
                            groupIsAlive.append(false)
                        }
                    }
                    if !groupIsAlive[0]{
                        dyingGroups[id] = group
                    }
                }
            }
        }else{
            for (id, group) in blackGroups{
                groupIsAlive.removeAll()
                if group.breath[killer.killerPosition] != nil{
                    for (breath, isValid) in group.breath{
                        if breath == killer.killerPosition{
                            continue
                        }
                        if isValid{
                            groupIsAlive.insert(true, at: 0)
                        }else{
                            groupIsAlive.append(false)
                        }
                    }
                    if !groupIsAlive[0]{
                        dyingGroups[id] = group
                    }
                }
            }
        }
        return dyingGroups
        
    }
    func checkKO(killer: Group)->Bool{
        var dyingGroups = checkIsKillable(killer: killer)
        simulateState.removeAll()

        // update tempstate and compare with the other one
        for (_, group) in blackGroups{
            if dyingGroups[group.id] != nil {
                continue
            }
            for (position, _) in group.position{
                simulateState[position] = true
            }
        }
        for (_, group) in whiteGroups{
            if dyingGroups[group.id] != nil {
                continue
            }
            for (position, _) in group.position{
                simulateState[position] = false
            }
        }
        killer.killerPosition = Array(killer.position.keys)[0]
        simulateState[killer.killerPosition] = killer.isBlack ? true : false
        
        if stateRecord.count < 3{
            return false
        }
        if simulateState == stateRecord[1]{
            // ko event..
            return true
        }
        return false
    }
    
    func invalidBreath(currentGroup: Group){
        for (_, group) in blackGroups{
            for (breath, _) in group.breath{
                if breath == currentGroup.killerPosition{
                    group.breath[breath] = false
                }
            }
        }
        for (_, group) in whiteGroups{
            for (breath, _) in group.breath{
                if breath == currentGroup.killerPosition{
                    group.breath[breath] = false
                }
            }
        }
    }
    
    func killThenMerge(killer: Group) -> Dictionary <CGPoint, Bool>{
        let dyingGroups = checkIsKillable(killer: killer)
        var idArray = [CGPoint]()
        state.removeAll()
        
        if killer.isBlack{
            for (id, group) in blackGroups{
                for breath in Array(group.breath.keys){
                    if breath == killer.killerPosition{
                        for (position, _) in group.position{
                            killer.position[position] = ""
                        }
                        for (breath, _) in group.breath{
                            killer.breath[breath] = true
                            if breath == killer.killerPosition{
                                killer.breath[breath] = nil
                            }
                        }
                        blackGroups[id] = nil
                    }
                }
            }
            blackGroups[killer.id] = killer
        }else{
            for (id, group) in whiteGroups{
                for breath in Array(group.breath.keys){
                    if breath == killer.killerPosition{
                        for (position, _) in group.position{
                            killer.position[position] = ""
                        }
                        for (breath, _) in group.breath{
                            killer.breath[breath] = true
                            if breath == killer.killerPosition{
                                killer.breath[breath] = nil
                            }
                        }
                        whiteGroups[id] = nil
                    }
                }
            }
            whiteGroups[killer.id] = killer
        }
        
        for (id, group) in dyingGroups{
            blackGroups[id] = nil
            whiteGroups[id] = nil
            for position in Array(group.position.keys){
                idArray.append(position)
            }
        }
        
        if killer.isBlack{
            for (_, group) in blackGroups{
                for point in idArray{
                    if group.breath[point] != nil{
                        group.breath[point] = true
                    }
                }
            }
        }else{
            for (_, group) in whiteGroups{
                for point in idArray{
                    if group.breath[point] != nil{
                        group.breath[point] = true
                    }
                }
            }
        }
        
        for (_, group) in blackGroups{
            for (position, _) in group.position{
                state[position] = true
            }
        }
        for (_, group) in whiteGroups{
            for (position, _) in group.position{
                state[position] = false
            }
        }
        stateRecord.insert(state, at: 0)
        if stateRecord.count > 3{
            stateRecord.remove(at: 3)
        }
        return state
    }
    
    func checkSuicide(currentGroup: Group) -> Bool{
        var isMerged = false
        if currentGroup.isBlack{
            for (_, group) in blackGroups{
                if group.breath[currentGroup.killerPosition] != nil{
                    isMerged = true
                    for (breath, isValid) in group.breath{
                        currentGroup.breath[breath] = isValid
                        if breath == currentGroup.killerPosition{
                            currentGroup.breath[breath] = nil
                        }
                    }
                }
                for (_, isValid) in currentGroup.breath{
                    if isValid{
                        return false
                    }
                }
            }
            if !isMerged{
                for (_, isValid) in currentGroup.breath{
                    if isValid{
                        return false
                    }
                }
            }
        }else{
            for (_, group) in whiteGroups{
                if group.breath[currentGroup.killerPosition] != nil{
                    isMerged = true
                    for (breath, isValid) in group.breath{
                        currentGroup.breath[breath] = isValid
                        if breath == currentGroup.killerPosition{
                            currentGroup.breath[breath] = nil
                        }
                    }
                }
                for (_, isValid) in currentGroup.breath{
                    if isValid{
                        return false
                    }
                }
            }
            if !isMerged{
                for (_, isValid) in currentGroup.breath{
                    if isValid{
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func mergeGroup(currentGroup: Group) -> Dictionary <CGPoint, Bool>{
        var idArray = [String]()
        if currentGroup.isBlack{
            for (id, group) in blackGroups{
                if group.breath[currentGroup.killerPosition] != nil{
                    idArray.append(id)
                    for (position, _) in group.position{
                        currentGroup.position[position] = ""
                    }
                    for (breath, isValid) in group.breath{
                        if isValid{
                            currentGroup.breath[breath] = true
                        }
                        if breath == currentGroup.killerPosition{
                            currentGroup.breath[breath] = nil
                        }
                    }
                }
            }
        }else{
            for (id, group) in whiteGroups{
                if group.breath[currentGroup.killerPosition] != nil{
                    idArray.append(id)
                    for (position, _) in group.position{
                        currentGroup.position[position] = ""
                    }
                    for (breath, isValid) in group.breath{
                        if isValid{
                            currentGroup.breath[breath] = true
                        }
                        if breath == currentGroup.killerPosition{
                            currentGroup.breath[breath] = nil
                        }
                    }
                }
            }
        }
        for id in idArray{
            blackGroups[id] = nil
            whiteGroups[id] = nil
        }
        if currentGroup.isBlack{
            blackGroups[currentGroup.id] = currentGroup
        }else{
            whiteGroups[currentGroup.id] = currentGroup
        }
        
        for (_, group) in blackGroups{
            for (position, _) in group.position{
                state[position] = true
            }
        }
        for (_, group) in whiteGroups{
            for (position, _) in group.position{
                state[position] = false
            }
        }
        stateRecord.insert(state, at: 0)
        if stateRecord.count > 3{
            stateRecord.remove(at: 3)
        }
        return state
    }
    
    func findSelectedGroup(boardPosition: CGPoint) -> Array <CGPoint>{
        var needMarkSpot = [CGPoint]()
        for (_, group) in blackGroups{
            if group.position[boardPosition] != nil{
                for (position, _) in group.position{
                    needMarkSpot.append(position)
                }
            }
        }
        for (_, group) in whiteGroups{
            if group.position[boardPosition] != nil{
                for (position, _) in group.position{
                    needMarkSpot.append(position)
                }
            }
        }
        return needMarkSpot
    }
}
