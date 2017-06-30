//
//  PlayerManager.swift
//  RecordNote
//
//  Created by aaron.zheng on 2017-06-29.
//  Copyright © 2017 aaron.zheng. All rights reserved.
//


import AVFoundation

protocol PlayerManagerDelegate {
    func playerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    func playerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?)
}

class PlayerManager: NSObject , AVAudioPlayerDelegate {
    
    var player:AVAudioPlayer!
    
    var url:NSURL? {
        get {
            if player != nil {
                return player.url  as NSURL?
            }
            
            return nil
        }
    }
    
    var isPlaying:Bool! {
        get {
            if player != nil {
                return player.isPlaying
            }
            
            return false
        }
    }
    
    var delegate: PlayerManagerDelegate!
    
    
    func play(_ url:URL) -> Bool {
        if player != nil {
            if player.url == url {
               return player.play()
            }
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self;
            player.prepareToPlay()
            return player.play()
        } catch {
            self.player = nil
            print("AVAudioPlayer init failed，\(error.localizedDescription)")
            return false
        }
    }
    
    func pause() {
        if player != nil {
            player.pause()
        }
    }
    
    func stop() {
        if player != nil {
            player.stop()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate.playerDidFinishPlaying(player, successfully: flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        delegate.playerDecodeErrorDidOccur(player, error: error)
    }
}

