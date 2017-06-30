//
//  ViewController.swift
//  RecordNote
//
//  Created by aaron.zheng on 2017-06-28.
//  Copyright © 2017 aaron.zheng. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UIGestureRecognizerDelegate,PlayerManagerDelegate {
    
    var recorder: AVAudioRecorder!
    
    var player: PlayerManager!
    
    var cacheURL = [URL]()
    
    @IBOutlet weak var recordBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if !cacheURL.isEmpty {
            cacheURL.removeAll()
        }
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        
        if cacheURL.count == 0 {
            return
        }
        
        if player!.isPlaying! {
            player.pause()
            
            recordBtn.setTitle("", for: .normal)
            recordBtn.setImage(UIImage(named: "play.png"), for: .normal)
        } else {
            let url = cacheURL.first
            let isSuccess = player.play(url!)
            print("play \((url!).lastPathComponent) \(isSuccess)")
            
            recordBtn.setTitle("", for: .normal)
            recordBtn.setImage(UIImage(named: "pause.png"), for: .normal)
        }
    }
    
    @IBAction func toSoundFilesVC(_ sender: UIBarButtonItem) {
        let soundFilesVC = SoundFilesTableViewController()
        soundFilesVC.items = cacheURL
        self.navigationController?.pushViewController(soundFilesVC, animated: true)
    }
    
    
    func setup() {
        
        player = PlayerManager()
        
        player.delegate = self
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleRecord(_:)))
        
        longPressGestureRecognizer.minimumPressDuration = 1.0
        
        longPressGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(longPressGestureRecognizer)
        
        self.setSessionPlayAndRecord()
    }
    
    
    func recordSetting() {
        
        let recordSettings:[String : Any] = [
            AVFormatIDKey:             kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey :      32000,
            AVNumberOfChannelsKey:     2,
            AVSampleRateKey :          44100.0
        ]
        
        
        do {
            let url = self.soundFileURL()
            cacheURL.append(url!)
            recorder = try AVAudioRecorder(url: url!, settings: recordSettings)
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
        } catch {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    
    func soundFileURL() -> URL? {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "\(format.string(from: Date())).m4a"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        print(soundFileURL)
        
        return soundFileURL
    }
    
    
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("set audiosession failed! error:\(error.localizedDescription)")
        }
        
        do {
            try session.setActive(true)
        } catch {
            print("active audiosession failed! error:\(error.localizedDescription)")
        }
    }
    
    
    func startRecord() {
        AVAudioSession.sharedInstance().requestRecordPermission() {
            [unowned self] granted in
            if granted {
                self.recordBtn.setImage(nil, for: .normal)
                self.recordBtn.setTitle("recording", for: .normal)
                self.recordSetting()
                let issuccess = self.recorder.record()
                print("is record success: \(issuccess)")
            } else {
                print("no permission to record !")
                
            }
        }
    }
    
    func stopRecord() {
        if self.recorder != nil {
            self.recorder.stop()
            self.recorder = nil
            
        }
    }
    
    func handleRecord(_ action: UILongPressGestureRecognizer) {
        if action.state == UIGestureRecognizerState.began {
            print("record began...")
            self.startRecord()
        } else if action.state == UIGestureRecognizerState.ended {
            self.stopRecord();
            recordBtn.setTitle("", for: .normal)
            recordBtn.setImage(UIImage(named: "play.png"), for: .normal)
            print("end")
        }
    }
    
    
    func playerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordBtn.setImage(UIImage(named: "play.png"), for: .normal)
    }
    
    func playerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        recordBtn.setImage(UIImage(named: "play.png"), for: .normal)
    }

}

