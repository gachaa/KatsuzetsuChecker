//
//  ResultViewController.swift
//  KatsuzetsuChecker
//
//  Created by 前本英里香 on 2017/04/26.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var timePointLabel: UILabel!
    @IBOutlet var accuracyPointLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    //checkVCからの答えとお題
    //answerArray = [言った言葉, タイム], questionArray = [言葉, 文字数, 基準タイム]
    var answerArray: [[Any]] = []
    var questionArray: [[Any]] = []
    
    
    var timePoint: Double = 0
    var accuracyPoint: Double = 0
    var point: Double = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ResultVC")
        
        compareText()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func compareText(){
        for k in 0..<3 {
            
            print(answerArray[k][0])
            
            var comparePoint: Double = questionArray[k][1] as! Double * 2
            print("comparePoint初期値", comparePoint)
            
            var question: String = questionArray[k][0] as! String
            question = question + question + question
            let answerPartsArray = makeArray(str: answerArray[k][0] as! String)
            let questionPartsArray = makeArray(str: question)
            
            var top = 0
            
            for i in 0..<questionPartsArray.count{
                var check = 0
                
                //各PartsArrayを比較して、違ったらcomparePに+1
                if top < i {
                    for j in top ..< i + 2 {
                        
                        if j >= answerPartsArray.count {
                            check = 1
                            break
                        }
                        
                        print(questionPartsArray[i], answerPartsArray[j])
                        if answerPartsArray[j] == questionPartsArray[i] {
                            top = j + 1
                            check = 0
                            break
                        } else {
                            check = 1
                        }
                    }
                } else {
                    for j in top..<top + 3 {
                        
                        if j >= answerPartsArray.count {
                            check = 1
                            break
                        }
                        
                        print(questionPartsArray[i], answerPartsArray[j])
                        if answerPartsArray[j] == questionPartsArray[i] {
                            top = j + 1
                            check = 0
                            break
                        } else {
                            check = 1
                        }
                    }
                }
                
                if check == 1 {
                    comparePoint -= 1
                    print(comparePoint)
                }
            }
            
            //pointに値を貯める
            timePoint += pointCheck(k: k, compare: comparePoint).0
            accuracyPoint += pointCheck(k: k, compare: comparePoint).1
            
            
        }
        
        //平均の点数を出す
        timePoint /= 3
        accuracyPoint /= 3
        point = (timePoint + accuracyPoint) / 2
        print("point最終", point)
        setAnyPointLabel()
    }

    //Stringを2文字ずつの要素にして配列にまとめるメソッド
    func makeArray(str: String) -> [String]{
        //arrayはstrの一文字ずつの配列
        let array: [String] = str.characters.map({String($0)})
        var resultArray: [String] = []
        for index in 0..<array.count {
            if index + 1 == array.count {break}
            let text = array[index] + array[index + 1]
            resultArray.append(text)
        }
        return resultArray
    }
    
    //得点を計算するメソッド
    func pointCheck(k: Int, compare: Double) -> (Double, Double) {
        var timePointCal: Double = 100
        var accuracyPointCal: Double = 100
        
        if (questionArray[k][2] as! Double) < (answerArray[k][1] as! Double) {
            timePointCal = 100 * (questionArray[k][2] as! Double) / (answerArray[k][1] as! Double)
            print("timeP", timePointCal)
        }
        
        print(compare)
        accuracyPointCal = 100 * Double(compare) / ((questionArray[k][1] as! Double) * 2)
        print("accuracyP", accuracyPointCal)
        
        return (timePointCal, accuracyPointCal)
    }
    
    
    func setAnyPointLabel() {
        if point > 99 {
            //ラベルに入らないから3桁だったら2桁にしてしまおう！
            point -= 1
        }
        pointLabel.text = "".appendingFormat("%.0f", point)
        
        if timePoint >= 90 {
            timePointLabel.text = "さいこう！"
        } else if timePoint >= 70 {
            timePointLabel.text = "いいかんじ"
        } else if timePoint >= 40 {
            timePointLabel.text = "まあまあ"
        } else {
            timePointLabel.text = "いまひとつ"
        }
        
        if accuracyPoint >= 90 {
            accuracyPointLabel.text = "さいこう！"
        } else if accuracyPoint >= 80 {
            accuracyPointLabel.text = "いいかんじ"
        } else if accuracyPoint >= 60 {
            accuracyPointLabel.text = "まあまあ"
        } else {
            accuracyPointLabel.text = "いまひとつ"
        }

    }
    
//    @IBAction func top(){
//        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//    }
    
        
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
