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

//使用label画出16个小格子
func CellLoad (SuperView:UIView){
    //清空
    CleanEverything(SuperView)
    
    var SuperWidth:CGFloat = SuperView.frame.width
    var SuperHight:CGFloat = CGFloat(SuperView.frame.height)
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
            var xx:CGFloat = CGFloat(i)
            var yy:CGFloat = CGFloat(j)
            
            var CellLabel:UILabel = UILabel(frame: CGRectMake(Padding*yy+CellWidth*(yy-1), Padding * xx + CellWidth * (xx-1), CellWidth, CellWidth)) //固定x时生成一列
            CellLabel.layer.cornerRadius = 10 //Label的Layer层可以控制圆角、颜色等，在background层之上
            CellLabel.layer.backgroundColor = myUIColor(255, 255, 255, 0.3).CGColor //UIColor可以用.CGColor方法转换为CGColor
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
            var randomIndex:Int = Int(arc4random_uniform(UInt32(EmptyCellsCoordinates.count))) //随机数种子应该先进行初始化，arc4random不需要初始化但是似乎没办法这样使用（似乎是因为Int8跟Int转换的问题）
            var randomNum:Int = (Int(arc4random() % 2) + 1) * 2
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
            Cell.textColor = myUIColor(0, 0, 0, 0)
        }else{
            Cell.textColor = myUIColor(255, 255, 255, 1)
        }
        Score += Cell.text!.toInt()!
    }
}


func moveLeft() -> Bool{
    var didMove:Bool = false

    //从左向右查找同一行中是否有不为0的格子，有的话跟当前为0格子对调数值，查询的方向与移动方向相反
    for i in 1 ... 4 {
        for j in 1 ... 4 {
            if CellDictionary["\(i),\(j)"]!.text == "0" {
                for y in j ... 4 {
                    if CellDictionary["\(i),\(y)"]!.text != "0" {
                        for var k = y+1; k < 5; ++k {
                            if stackCells("\(i),\(y)", "\(i),\(k)") {
                                break
                            }
                        }
                        moveCells("\(i),\(j)", "\(i),\(y)")
                        didMove = true
                        break
                    }
                }
            } else {
                for var k = j+1; k < 5; ++k {
                    if stackCells("\(i),\(j)", "\(i),\(k)") {
                        didMove = true
                        break
                    }
                }
            }
        }
    }
    
    return didMove

}

func moveRight() -> Bool{
    var didMove:Bool = false
    
    /*
    从右向左查找同一行中是否有不为0的格子，
    若有：左侧是否有格子相同且只相隔空格子，相同则叠加，并跟当前为0格子对调数值
    */
    for i in 1 ... 4 {
        for var j = 4; j > 0 ; j-- {
            if CellDictionary["\(i),\(j)"]!.text == "0" { //当前为空格子
                for var y = j ; y > 0; --y { // 遍历当前行
                    if CellDictionary["\(i),\(y)"]!.text != "0" { //找到第一个非空格子
                        for var k = y-1; k > 0; --k {
                            if stackCells("\(i),\(y)", "\(i),\(k)") {
                                break
                            }
                        }
                        moveCells("\(i),\(j)", "\(i),\(y)")
                        didMove = true
                        break
                    }
                }
            } else {  //当前格子非空
                for var k = j-1; k > 0; --k {
                    if stackCells("\(i),\(j)", "\(i),\(k)") {
                        didMove = true
                        break
                    }
                }
            }
        }
    }
    
    return didMove

}

func moveUp() -> Bool{
    var didMove:Bool = false
    //从上向下查找同一列中是否有不为0的格子，有的话跟当前为0格子对调数值
    for i in 1 ... 4 {
        for j in 1 ... 4 {
            if CellDictionary["\(i),\(j)"]!.text == "0" {
                for x in i ... 4 {
                    if CellDictionary["\(x),\(j)"]!.text != "0" {
                        for var k = x+1; k<5; ++k {
                            if stackCells("\(x),\(j)", "\(k),\(j)") {
                                break
                            }
                        }
                        moveCells("\(i),\(j)", "\(x),\(j)")
                        didMove = true
                        break
                    }
                }
            } else {
                for var k = i+1; k<5; ++k {
                    if stackCells("\(i),\(j)", "\(k),\(j)") {
                        didMove = true
                        break
                    }
                }
            }
        }
    }
    
    return didMove

}

func moveDown() -> Bool{
    var didMove:Bool = false

    //从下向上查找同一列中是否有不为0的格子，有的话跟当前为0格子对调数值
    for var i = 4 ; i > 0; --i {
        for var j = 4; j > 0; --j {
            if CellDictionary["\(i),\(j)"]!.text == "0" {
                for var x = i ; x > 0; --x {
                    if CellDictionary["\(x),\(j)"]!.text != "0" {
                        for var k = x-1; k>0; --k {
                            if stackCells("\(x),\(j)", "\(k),\(j)") {
                                break
                            }
                        }
                        moveCells("\(i),\(j)", "\(x),\(j)")
                        didMove = true
                        break
                    }
                }
            } else {
                for var k=i-1; k>0; --k {
                    if stackCells("\(i),\(j)", "\(k),\(j)") {
                        didMove = true
                        break
                    }
                }
            }
        }
    }
    
    return didMove

}

func moveCells(originalCell:String, operateCell:String) {
    CellDictionary[originalCell]!.text = CellDictionary[operateCell]!.text
    CellDictionary[operateCell]!.text = "0"
    updateEmptyCells(originalCell, operateCell)

}
func stackCells(originalCell:String, operateCell:String) -> Bool {
    if CellDictionary[operateCell]!.text == "0" {
        return false
    } else if CellDictionary[originalCell]!.text == CellDictionary[operateCell]!.text {
        CellDictionary[originalCell]!.text = String( CellDictionary[operateCell]!.text.toInt()! * 2 )
        CellDictionary[operateCell]!.text = "0"
        getCurrentMaxNum(CellDictionary[operateCell]!)
        updateEmptyCells(originalCell, operateCell)
        return true
    } else {
        return true
    }
}

func updateEmptyCells(originalCell:String, operateCell:String){
    for (index,contents) in enumerate(EmptyCellsCoordinates) {
        if contents == originalCell {
            EmptyCellsCoordinates.removeAtIndex(index)
        }
    }
    EmptyCellsCoordinates.append(operateCell)
}

func notyetGameOver() -> Bool {
    var gameOver:Bool = false
    
    println(EmptyCellsCoordinates.count)
    
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
    CurrentMaxNum = ((cellToCompare.text.toInt()! > CurrentMaxNum) ? cellToCompare.text.toInt()! : CurrentMaxNum)
}

