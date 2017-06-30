//
//  SoundFilesTableViewController.swift
//  RecordNote
//
//  Created by aaron.zheng on 2017-06-29.
//  Copyright © 2017 aaron.zheng. All rights reserved.
//

import UIKit
import AVFoundation

class SoundFilesTableViewController: UITableViewController,PlayerManagerDelegate {
    
    var items = [URL]()
    var player:PlayerManager!
    var currentIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if items.isEmpty {
            self.fetchItems()
        }
        
        player = PlayerManager()
        player.delegate = self;
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if player != nil {
            player.stop();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func fetchItems() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            self.items = urls.filter( { (name: URL) -> Bool in
                return name.lastPathComponent.hasSuffix("m4a")
            })
            
        } catch {
            print("fetchItems error! \(error.localizedDescription)")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "cell"
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
        
        if currentIndex == indexPath.row {
            if player != nil {
                if player!.isPlaying! {
                    cell.imageView?.image = UIImage(named: "pause.png")
                } else {
                    cell.imageView?.image = UIImage(named: "play.png")
                }
            } else {
                cell.imageView?.image = UIImage(named: "play.png")
            }
        } else {
            cell.imageView?.image = UIImage(named: "play.png")
        }
        
        cell.textLabel?.text = self.items[indexPath.row].lastPathComponent
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.currentIndex {
            if self.player != nil {
                if self.player!.isPlaying! {
                    player.pause()
                }else {
                    let url = self.items[indexPath.row]
                    let isSuccess = player.play(url)
                    print("play \(url.lastPathComponent) \(isSuccess)")
                }
            }
        }else {
            let url = self.items[indexPath.row]
            let isSuccess = player.play(url)
            print("play \(url.lastPathComponent) \(isSuccess)")
        }
        
        self.currentIndex = indexPath.row

        tableView.reloadData()
    }
    
    func playerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        tableView.reloadData()
    }
    
    func playerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        tableView.reloadData()
    }
    
}
