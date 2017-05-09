//
//  CheckViewController.swift
//  KatsuzetsuChecker
//
//  Created by 前本英里香 on 2017/04/26.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit
import Speech

class CheckViewController: UIViewController {

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    //どうぞしゃべってくださいのラベル
    @IBOutlet weak var douzoLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    //お題を表示するラベル
    @IBOutlet var tTLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    //言った言葉が表示されるラベル
    @IBOutlet var label: UILabel!
    
    //早口言葉の配列[言葉, Sランクに必要なタイム, Aランク,　Bランク]
    var tongueTwisterArray: [[Any]] = []
    var tmpArray: [[Any]] = []
    var tTCount: Int = 0
    
    var timer: Timer!
    var count: Double = 0
    
    //ラベルに変化がないか調べるセット
    var timerCheck:Int = 0
    var finishTimer: Timer!
    var preText: String = "pre"
    var nowText: String = "now"
    
    //得点を出すための配列、[言った言葉, タイム]
    var answer: [[Any]] = []

    
    
    public override func viewDidLoad() {
        print("checkview")
        super.viewDidLoad()
        
        speechRecognizer.delegate = self
        
        //------------------------ここから下に早口言葉を書く------------------------//
        tmpArray.append(["あいうえお", 1, 2, 3])
        tmpArray.append(["かきくけこ", 1, 2, 3])
        tmpArray.append(["さしすせそ", 1, 2, 3])
        //------------------------ここから上に早口言葉を書く------------------------//
        
        //ランダムに3つ入ったtTArrayができる。
        choiceTongueTwister()
        
        //ボタンを無効にする
        button.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestRecognizerAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    //タイム測定のためのメソッド
    func up(){
        count += 0.01
        timeLabel.text = "".appendingFormat("%.2f", count)
    }
    
    //tongueTwisterArrayにtemArrayを入れるメソッド。引数で何個入れるか決める。とりあえず3
    func choiceTongueTwister(){
        for _ in 0..<3 {
            let index = Int(arc4random_uniform(UInt32(tmpArray.count)))
            tongueTwisterArray.append(tmpArray[index])
            tmpArray.remove(at: index)
        }
        setTTLabel()
    }
    
    //tTLabelに早口言葉を表示
    func setTTLabel(){
        if tTCount < 3{
            tTLabel.text = tongueTwisterArray[tTCount][0] as? String
        } else {
            tTLabel.text = "Finish"
        }
    }
    
    
    //viewDidAppearで呼ばれるメソッド
    private func requestRecognizerAuthorization() {
        // 認証処理　ユーザーに許可を求める
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // メインスレッドで処理したい内容のため、OperationQueue.main.addOperationを使う
            OperationQueue.main.addOperation { [weak self] in
                guard let `self` = self else { return }
                
                //ここに音声認識の許可されてる/されてないの時の処理
                switch authStatus {
                case .authorized:
                    //色々許可されてればここが呼ばれている
                    self.button.isEnabled = true
                    
                case .denied:
                    self.button.isEnabled = false
                    self.button.setTitle("音声認識へのアクセスが拒否されています。", for: .disabled)
                    
                case .restricted:
                    self.button.isEnabled = false
                    self.button.setTitle("この端末で音声認識はできません。", for: .disabled)
                    
                case .notDetermined:
                    self.button.isEnabled = false
                    self.button.setTitle("音声認識はまだ許可されていません。", for: .disabled)
                }
            }
        }
    }
    
    //録音を開始した時に呼ばれるメソッド
    private func startRecording() throws {
    
        print("startRecording")
        
        //recognitionTaskを空にする
        refreshTask()
        
        let audioSession = AVAudioSession.sharedInstance()
        // 録音用のカテゴリをセット
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // 録音が完了する前のリクエストを作るかどうかのフラグ。
        // trueだと現在-1回目のリクエスト結果が返ってくる模様。falseだとボタンをオフにしたときに音声認識の結果が返ってくる設定。
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) {
            [weak self] result, error in
            guard let `self` = self else { return }
            
            var isFinal = false

            //nilじゃなかったら
            if let result = result {
                self.label.text = result.bestTranscription.formattedString
            
                self.nowText = result.bestTranscription.formattedString

                isFinal = result.isFinal
            
                //一回しか呼ばれない。書き方変えた方がいいかも
                if self.timerCheck == 0 {
                    self.finishTimer = Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: #selector(self.finishCheck), userInfo: nil, repeats: true)
                    self.timerCheck = 1
                }
            }
            
            print("result終")

            // エラーがある、もしくは最後の認識結果だった場合の処理
            if error != nil || isFinal {
                print("e")
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.douzoLabel.text = ""
                
                self.button.setTitle("音声認識スタート", for: [])
            }
        }
        
        // マイクから取得した音声バッファをリクエストに渡す
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        try startAudioEngine()
    }

    //録音開始直後に呼ばれる
    private func refreshTask() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    
    //starRecordingで呼ばれる
    private func startAudioEngine() throws {
        // startの前にリソースを確保しておく。
        audioEngine.prepare()
        
        try audioEngine.start()
        
        douzoLabel.text = "認識中"
    }
    
    //読み終えたかのチェック。終えてたら音声認識を終了し、終えていなければpreとnowを更新
    func finishCheck(){
        print("finishcheck")
        print(preText, nowText)
        
        if preText == nowText {
            print("finishfinish")
            
            //音声認識を止める
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            //button.setTitle("停止中", for: .disabled)
            douzoLabel.text = "停止中"
            finishTimer.invalidate()
            
            //得点のためのタイマーをとめる
            timer.invalidate()
            
            answer.append([nowText, count])
            
            nowText = "now"
            preText = "pre"
            
            //問題出しきってたら画面遷移、違うならお題のラベルセットしてtTCount上げる
            if tTCount == 2 {
                performSegueToResultView()
            } else {
                tTCount += 1
                setTTLabel()
                self.button.isHidden = false
            }
        }
        self.preText = self.nowText
    }
    
    @IBAction func tappedStartButton(_ sender: AnyObject) {
        //音声認識ストップするときの処理
//        if audioEngine.isRunning {
//            print("stop")
//            audioEngine.stop()
//            recognitionRequest?.endAudio()
//            button.isEnabled = false
//            timer.invalidate()
//            button.setTitle("停止中", for: .disabled)
            
            
        //音声認識スタートする時の処理
        if audioEngine.isRunning == false {
            label.text = ""
            timerCheck = 0
            try! startRecording()
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.up), userInfo: nil, repeats: true)
            count = 0
            //button.setTitle("音声認識を中止", for: [])
            button.isHidden = true
        }
    }
    
    //画面遷移のためのメソッド
    func performSegueToResultView() {
        performSegue(withIdentifier: "toResultView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toResultView") {            
            let resultView = segue.destination as! ResultViewController
            resultView.answer = self.answer
        }
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

extension CheckViewController: SFSpeechRecognizerDelegate {
    // 音声認識の可否が変更したときに呼ばれるdelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            //ここいつくるんだろう
            button.isEnabled = true
            button.setTitle("音声認識スタート", for: [])
        } else {
            //ネット繋がれてないとここにくる
            button.isEnabled = false
            button.setTitle("音声認識ストップ", for: .disabled)
        }
    }
}
