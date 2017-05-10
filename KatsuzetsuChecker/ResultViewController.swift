//
//  ResultViewController.swift
//  KatsuzetsuChecker
//
//  Created by 前本英里香 on 2017/04/26.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    //checkVCからの答えとお題
    //answerArray = [言った言葉, タイム], questionArray = [言葉, 文字数, 基準タイム]
    var answerArray: [[Any]] = []
    var questionArray: [[Any]] = []
    
    //どのくらい異なってるかをとりあえずカウント
    var comparePointArray: [Int] = [0, 0, 0]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ResultVC")
        
        print(questionArray)
        print(answerArray)
        compareText()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func compareText(){
        for k in 0..<3 {
            
            var question: String = questionArray[k][0] as! String
            question = question + question + question
            let answerPartsArray = makeArray(str: answerArray[k][0] as! String)
            let questionPartsArray = makeArray(str: question)
            
            print(questionPartsArray, answerPartsArray)
            print(questionPartsArray.count, answerPartsArray.count)
            
            var top = 0
            
            for i in 0..<questionPartsArray.count{
                print("i: ", i)
                var check = 0
                
                //各PartsArrayを比較して、違ったらcomparePに+1
                if top < i {
                    for j in top ..< i + 2 {
                        
                        if j >= answerPartsArray.count {
                            check = 1
                            break
                        }
                        
                        print(answerPartsArray[j], questionPartsArray[i])
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
                        
                        print(answerPartsArray[j], questionPartsArray[i])
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
                    comparePointArray[k] += 1
                }
            }
            
        }
        
        
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
    func pointCheck(){
        var timePoint: Double = 0
        var accuracyPoint: Double = 0
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
