//
//  ResultViewController.swift
//  KatsuzetsuChecker
//
//  Created by 前本英里香 on 2017/04/26.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    var answer: [[Any]] = []
    var question: String = ""
    
    //どのくらい異なってるかをとりあえずカウント
    var comparePoint: Int = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func compareText() {
        
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
