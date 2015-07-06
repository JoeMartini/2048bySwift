//
//  InitializationModel.swift
//  2048byswift
//
//  Created by Martini Wang on 14-8-22.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

//方便换算颜色
func myUIColor (R:Int, G:Int, B:Int, A:Float) -> UIColor {
    return UIColor(red: CGFloat(R)/255.0, green: CGFloat(G)/255.0, blue: CGFloat(B)/255.0, alpha: CGFloat(A))
}

//建立一个字典存储小格子们
var CellDictionary:Dictionary = Dictionary<String,UILabel>()

//空格子做标数组
var EmptyCellsCoordinates:Array = Array(CellDictionary.keys)

//储存得分
var Score:Int = 0

//当前方格中最大数字
var CurrentMaxNum:Int = 0

var didMove:Bool = false

//使用label画出16个小格子
func CellLoad (SuperView:UIView){
    //清空
    CleanEverything(SuperView)
    
    let SuperWidth:CGFloat = SuperView.frame.width
    let SuperHight:CGFloat = CGFloat(SuperView.frame.height)
    let SuperSize = (SuperView.frame.width,SuperView.frame.height)
    var CellWidth:CGFloat
    var Padding:CGFloat
    
    switch SuperSize {
    case let(x,y) where x > y :
        CellWidth = SuperHight / 4 * 0.75
        Padding = SuperHight * 0.25 / 5
    case let(x,y) where x < y :
        CellWidth = SuperWidth / 4 * 0.75
        Padding = SuperWidth * 0.25 / 5
    default:
        CellWidth = SuperWidth / 4 * 0.75
        Padding = SuperWidth * 0.25 / 5
    }
    
    for i in 1...4 {
        for j in 1...4 {
            let xx:CGFloat = CGFloat(i)
            let yy:CGFloat = CGFloat(j)
            
            let CellLabel:UILabel = UILabel(frame: CGRectMake(Padding*yy+CellWidth*(yy-1), Padding * xx + CellWidth * (xx-1), CellWidth, CellWidth)) //固定x时生成一列
            CellLabel.layer.cornerRadius = 10 //Label的Layer层可以控制圆角、颜色等，在background层之上
            CellLabel.layer.backgroundColor = myUIColor(255, G: 255, B: 255, A: 0.3).CGColor //UIColor可以用.CGColor方法转换为CGColor
            CellLabel.textColor = UIColor.whiteColor()
            CellLabel.font = UIFont.boldSystemFontOfSize(26)
            CellLabel.textAlignment = NSTextAlignment.Center
            CellLabel.text = "0" //"\(i+j-2)"
            
            //把格子存进字典
            CellDictionary["\(i),\(j)"]=CellLabel
            
            SuperView.addSubview(CellLabel)
        }
    }
    EmptyCellsCoordinates = Array(CellDictionary.keys)//初始状态所有格子都是空的
    //println("\(EmptyCellsCoordinates.count)")
    CurrentMaxNum = 0 //初始状态数字为0
}

//遍历View的所有Subview并删除
func CleanEverything (ViewToClean:UIView) {
    for item in ViewToClean.subviews {
        item.removeFromSuperview()
    }
    CellDictionary.removeAll()
    EmptyCellsCoordinates = Array(CellDictionary.keys)
}

//产生随机数格子
func CreatNumedCell(Times:Int){
    if EmptyCellsCoordinates.count != 0 {
        for i in 1 ... Times {
            let randomIndex:Int = Int(arc4random_uniform(UInt32(EmptyCellsCoordinates.count))) //随机数种子应该先进行初始化，arc4random不需要初始化但是似乎没办法这样使用（似乎是因为Int8跟Int转换的问题）
            let randomNum:Int = (Int(arc4random() % 2) + 1) * 2
            CellDictionary["\( EmptyCellsCoordinates[randomIndex])"]!.text = "\(randomNum)"
            EmptyCellsCoordinates.removeAtIndex(randomIndex)
        }
    }
}

//刷新格子显示，若数字不为0，则把数字显示出来，否则隐藏掉
func RefreshCells() {
    Score = 0
    for (Position , Cell) in CellDictionary {
        if Cell.text == "0" {
            Cell.textColor = myUIColor(0, G: 0, B: 0, A: 0)
        }else{
            Cell.textColor = myUIColor(255, G: 255, B: 255, A: 1)
        }
        Score += Int(Cell.text!)!
    }
}


func moveLeft() -> Bool{
    didMove = false

    //从左向右查找同一行中是否有不为0的格子，有的话跟当前为0格子对调数值，查询的方向与移动方向相反
    for i in 1 ... 4 {
        var emptyRow:Bool = true
        for j in 1 ... 4 {
            if CellDictionary["\(i),\(j)"]!.text == "0" {
                for y in j ... 4 {
                    if CellDictionary["\(i),\(y)"]!.text != "0" {
                        emptyRow = false
                        for var k = y+1; k < 5; ++k {
                            if stackCells("\(i),\(y)", operateCell: "\(i),\(k)") {
                                break
                            }
                        }
                        moveCells("\(i),\(j)", operateCell: "\(i),\(y)")
                        //didMove = true
                        break
                    }
                }
            } else {
                emptyRow = false
                for var k = j+1; k < 5; ++k {
                    if stackCells("\(i),\(j)", operateCell: "\(i),\(k)") {
                        //didMove = true
                        break
                    }
                }
            }
            if emptyRow {
                break
            }
        }
    }
    
    return didMove

}

func moveRight() -> Bool{
    didMove = false
    
    /*
    从右向左查找同一行中是否有不为0的格子，
    若有：左侧是否有格子相同且只相隔空格子，相同则叠加，并跟当前为0格子对调数值
    */
    for i in 1 ... 4 {
        var emptyRow:Bool = true
        for var j = 4; j > 0 ; j-- {
            if CellDictionary["\(i),\(j)"]!.text == "0" { //当前为空格子
                for var y = j ; y > 0; --y { // 遍历当前行
                    if CellDictionary["\(i),\(y)"]!.text != "0" { //找到第一个非空格子
                        emptyRow = false
                        for var k = y-1; k > 0; --k {
                            if stackCells("\(i),\(y)", operateCell: "\(i),\(k)") {
                                break
                            }
                        }
                        moveCells("\(i),\(j)", operateCell: "\(i),\(y)")
                        break
                    }
                }
            } else {  //当前格子非空
                emptyRow = false
                for var k = j-1; k > 0; --k {
                    if stackCells("\(i),\(j)", operateCell: "\(i),\(k)") {
                        break
                    }
                }
            }
            if emptyRow {
                break
            }
        }
    }
    
    return didMove

}

func moveUp() -> Bool{
    didMove = false
    //从上向下查找同一列中是否有不为0的格子，有的话跟当前为0格子对调数值
    for j in 1 ... 4 {
        var emptyColumn:Bool = true
        for i in 1 ... 4 {
            if CellDictionary["\(i),\(j)"]!.text == "0" {
                for x in i ... 4 {
                    if CellDictionary["\(x),\(j)"]!.text != "0" {
                        emptyColumn = false
                        for var k = x+1; k<5; ++k {
                            if stackCells("\(x),\(j)", operateCell: "\(k),\(j)") {
                                break
                            }
                        }
                        moveCells("\(i),\(j)", operateCell: "\(x),\(j)")
                        break
                    }
                }
            } else {
                emptyColumn = false
                for var k = i+1; k<5; ++k {
                    if stackCells("\(i),\(j)", operateCell: "\(k),\(j)") {
                        break
                    }
                }
            }
            if emptyColumn {
                break
            }
        }
    }
    
    return didMove

}

func moveDown() -> Bool{
    didMove = false

    //从下向上查找同一列中是否有不为0的格子，有的话跟当前为0格子对调数值
    for var j = 4; j > 0; --j {
        var emptyColumn:Bool = true
        for var i = 4 ; i > 0; --i {
            if CellDictionary["\(i),\(j)"]!.text == "0" {
                for var x = i - 1 ; x > 0; --x {
                    if CellDictionary["\(x),\(j)"]!.text != "0" {
                        emptyColumn = false
                        for var k = x-1; k>0; --k {
                            if stackCells("\(x),\(j)", operateCell: "\(k),\(j)") {
                                break
                            }
                        }
                        moveCells("\(i),\(j)", operateCell: "\(x),\(j)")
                        break
                    }
                    emptyColumn = true
                }
            } else {
                emptyColumn = false
                for var k=i-1; k>0; --k {
                    if stackCells("\(i),\(j)", operateCell: "\(k),\(j)") {
                        break
                    }
                }
            }
            if emptyColumn {
                break
            }
        }
    }
    
    return didMove

}

func moveCells(originalCell:String, operateCell:String) {
    CellDictionary[originalCell]!.text = CellDictionary[operateCell]!.text
    CellDictionary[operateCell]!.text = "0"
    updateEmptyCells(originalCell, operateCell: operateCell)
    didMove = true
}
func stackCells(originalCell:String, operateCell:String) -> Bool {
    if CellDictionary[operateCell]!.text == "0" {
        return false
    } else if CellDictionary[originalCell]!.text == CellDictionary[operateCell]!.text {
        CellDictionary[originalCell]!.text = String( Int(CellDictionary[operateCell]!.text!)! * 2 )
        CellDictionary[operateCell]!.text = "0"
        getCurrentMaxNum(CellDictionary[operateCell]!)
        updateEmptyCells(originalCell, operateCell: operateCell)
        didMove = true
        return true
    } else {
        return true
    }
}

func updateEmptyCells(originalCell:String, operateCell:String){
    for (index,contents) in EmptyCellsCoordinates.enumerate() {
        if contents == originalCell {
            EmptyCellsCoordinates.removeAtIndex(index)
        }
    }
    EmptyCellsCoordinates.append(operateCell)
}

func notyetGameOver() -> Bool {
    var gameOver:Bool = false
    
    print(EmptyCellsCoordinates.count)
    
    if EmptyCellsCoordinates.count == 0 {
        for i in 1 ... 3 {
            for j in 1 ... 3 {
                if CellDictionary["\(i),\(j)"]!.text == CellDictionary["\(i+1),\(j)"]!.text || CellDictionary["\(i),\(j)"]!.text == CellDictionary["\(i),\(j+1)"]!.text {
                    gameOver = true
                    break
                }
            }
        }
    } else {
        gameOver = true
    }
    return gameOver
}

func getCurrentMaxNum(cellToCompare:UILabel){
    CurrentMaxNum = ((Int(cellToCompare.text!)! > CurrentMaxNum) ? Int(cellToCompare.text!)! : CurrentMaxNum)
}

