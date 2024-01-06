//
//  Game.swift
//  OneMinutes
//
//  Created by Дима on 07.10.2023.
//

import Foundation

enum StasusGame{
    case start
    case win
    case lose
    
}

class Game{
    
    struct Item {
        var title: String
        var isFound: Bool = false
        var isError = false
        
    }
    
    private let data = Array(1...99)
    
     var items:[Item] = []
    
    private var countItems:Int
    
    var nextItem:Item?
    
    var isNewRecord = false
    
    var status :StasusGame = .start{
        didSet{
            if status != .start{
                if status == .win{
                    let newRecord = timeForGame - secondsGame
                    
                    let record = UserDefaults.standard.integer(forKey: keysUserDefaulets.recordGame)
                    
                    if record == 0 || newRecord < record{
                        UserDefaults.standard.setValue(newRecord, forKey: keysUserDefaulets.recordGame)
                        isNewRecord = true
                    }
                }
                stopGame()
            }
        }
    }
    private var timeForGame:Int
    private var secondsGame :Int{
        didSet{
            if secondsGame == 0{
                status = .lose
            }
            updateTimer(status,secondsGame)
        }
    }
    
    private var timer:Timer?
    private var updateTimer:((StasusGame, Int)->())
    
    init(countItems: Int, updateTimer:@escaping (_ status: StasusGame,_ second:Int)->()) {
        self.countItems = countItems
        self.timeForGame = Settings.sehared.currentSetings.timeForGame
        self.secondsGame = self.timeForGame
        self.updateTimer = updateTimer
        setupGame()
    }
    
    private func setupGame(){
        isNewRecord = false
        var digits = data.shuffled()
        items.removeAll()
        while items.count < countItems{
            let item = Item(title: String(digits.removeFirst()))
            items.append(item)
        }
        
        nextItem = items.shuffled().first
        updateTimer(status,secondsGame)
        
        if Settings.sehared.currentSetings.timeState{
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
                self?.secondsGame -= 1
            })
        }
    }
    func newGame(){
        status = .start
        self.secondsGame = self.timeForGame
        setupGame()
    }
    
    
    
    func check(index:Int){
        guard status == .start else {return}
        if items[index].title == nextItem?.title{
            items[index].isFound = true
            nextItem = items.shuffled().first(where: {(item) -> Bool in item.isFound == false
            })
        }else{
            items[index].isError = true
        }
        
        
        if nextItem == nil{
            status = .win
        }
    }
     func stopGame(){
        timer?.invalidate()
    }
    
}

extension Int{
    func secondToString()->String{
        let minute = self/60
        let second = self%60
        
        return String(format: "%d:%02d", minute, second)
    }
}