//
//  ViewController.swift
//  2048byswift
//
//  Created by Martini Wang on 14-8-21.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIAlertViewDelegate {
                            
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var StartGameButton: UIButton!
    @IBOutlet weak var GameAreaView: UIView!
    @IBOutlet var swipeLeft: UISwipeGestureRecognizer!
    @IBOutlet var swipeRight: UISwipeGestureRecognizer!
    @IBOutlet var swipeUp: UISwipeGestureRecognizer!
    @IBOutlet var swipeDown: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GameAreaView.hidden = true
        ScoreLabel.hidden = true
        swipesLoad(GameAreaView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func StartGame(Sender:UIButton){
        GameAreaView.backgroundColor = myUIColor(255,205,112,1.0)
        GameAreaView.layer.cornerRadius = 10
        CellLoad(GameAreaView)
        CreatNumedCell(2)
        GameAreaView.hidden = false
        RefreshCells()

        ScoreLabel.hidden = false
        StartGameButton.setTitle("New Game", forState: nil)
        ScoreLabel.text! = "Current score: \(Score)"
    }
    
    @IBAction func swipeOnGameAreaView(Sender:UISwipeGestureRecognizer){
        //获取划动方向
        var currentSwipeDirection = Sender.direction.rawValue  //得到方向的数字代号
        switch currentSwipeDirection {
        case 1 :
            if moveRight() && notyetGameOver() {
                CreatNumedCell(1)
                RefreshCells()
            } else {
                gameDidOver()
            }
            //println("Right")
        case 2 :
            println("Left")
            if moveLeft() && notyetGameOver()  {
                CreatNumedCell(1)
                RefreshCells()
            } else {
                gameDidOver()
            }
        case 4 :
            if moveUp() && notyetGameOver()  {
                CreatNumedCell(1)
                RefreshCells()
            } else {
                gameDidOver()
            }
            //println("Up")
        case 8 :
            if moveDown() && notyetGameOver()  {
                CreatNumedCell(1)
                RefreshCells()
            } else {
                gameDidOver()
            }
            //println("Down")
        default :
            println("Error")
        }
        //检测滑动方向上是否有空格子
        //检测滑动方向上是否发生叠加
        //移动格子并叠加数字
        //空出来的格子先用空格子填充
        //在所有空格子中随机产生1个随机2or4
        //游戏是否结束
        ScoreLabel.text! = "Current score: \(Score)"
    }
    
    func gameDidOver() {
        if !notyetGameOver() {
            var GameOverWarning:UIAlertView = UIAlertView(title: "Game Over", message: "Try Again", delegate: self, cancelButtonTitle: "OK")
            GameOverWarning.show()
        } else {
            RefreshCells()
        }
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        StartGame(StartGameButton)
    }
    
    func swipesLoad(ViewToAdd:UIView) {
        
        //将swipe事件指向名为“swipeOnGameAreaView”的回调函数
        swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeOnGameAreaView:")
        swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeOnGameAreaView:")
        swipeUp = UISwipeGestureRecognizer(target: self, action: "swipeOnGameAreaView:")
        swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeOnGameAreaView:")
        
        //控件默认状态下只监控从左向右的滑动，通过设置Direction（get属性）可以指定不同的控件监控不同的滑动
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        
        ViewToAdd.addGestureRecognizer(swipeLeft)
        ViewToAdd.addGestureRecognizer(swipeRight)
        ViewToAdd.addGestureRecognizer(swipeUp)
        ViewToAdd.addGestureRecognizer(swipeDown)
        
        ViewToAdd.userInteractionEnabled = true
    }
    
}

