//
//  AudioManager.swift
//  StopWatch
//
//  Created by 向辉 on 2018/6/21.
//  Copyright © 2018 Lance. All rights reserved.
//

import Foundation
import AVFoundation

/*
    声音管理器：为按钮点击事件添加上按键音
 */
class AudioPlayerManagr {
  static var sharedManager = AudioPlayerManagr()
  private init() {}
  
  var audioPlayer: AVAudioPlayer?
  var audioFilePath: String?
  
  func palySoundEffect() {
    
    if audioFilePath == nil {
      audioFilePath = Bundle.main.path(forResource: "buttonSound", ofType: "wav")
    }
    
    guard let path = audioFilePath else { return }
    
    if audioPlayer == nil {
      audioPlayer = try? AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: path), fileTypeHint: nil)
    }
    audioPlayer?.play()
  }
  
}
