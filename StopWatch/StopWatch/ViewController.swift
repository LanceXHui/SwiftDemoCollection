//
//  ViewController.swift
//  StopWatch
//
//  Created by 向辉 on 2018/6/21.
//  Copyright © 2018 Lance. All rights reserved.
//
//
//  ** No1:
//     在label上的数字在变化的时候，其实字体不一样效果也是有很大的差别的，如果是系统字体的话，会出现数字变化
//     时候UILabel有跳动现象，原因是系统字体每一个字符的大家都不是一样的，但是我更换其他字体之后就可以了
//  ** No2:
//     这里的关键是使用了RxSwift,虽然使用得非常的浅显，但是，这也是进步不是吗？
//     So, Come On...
//  ** No3:
//     接下来要做的事情： 封装一个倒计时的UILabel；面向协议编程封装黑夜模式
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class ViewController: UIViewController {
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var resetButton: UIButton!
  @IBOutlet weak var pauseButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  
  let currentNumber = Variable<Double>(0.0)  // 当前显示的数值
  let isRuning = Variable<Bool>(false)       // 显示当前的计时状态的变化
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    // 将currentNumbere的值和countLabel的显示绑定起来！
    currentNumber.asObservable()
      .map { String.init(format: "%.1f", $0) }
      .debug()
      .bind(to: countLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 将isRuning状态和计时器的创建联系起来
    // --skipWhile 表明知道接受到true才开始计时
    // --distinctUntilChanged 表明不连续接收一样的事件
    // 当flatMapLatest多次调用的时候，其实是创建的很多新的观察序列，原观察序列还在，但是subscriber却不订阅原序列了
    isRuning.asObservable()
      .debug()
      .skipWhile{ $0 == true }
      .distinctUntilChanged()
      .flatMapLatest { (isRuning) in
        isRuning ? Observable<Int>.interval(0.1, scheduler: MainScheduler.asyncInstance) : .empty()
      }
      .subscribe({ [weak self] (event) in
        guard let `self` = self else { return }
        self.currentNumber.value = self.currentNumber.value + 0.1
        
        print("\(event.element!)")
      })
      .disposed(by: disposeBag)
    
    /// 将三个不同按钮的点击事件和isRuning的值关联起来
    startButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.isRuning.value = true
        
        AudioPlayerManagr.sharedManager.palySoundEffect()
      }).disposed(by: disposeBag)
    
    pauseButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.isRuning.value = false
        
        AudioPlayerManagr.sharedManager.palySoundEffect()
    }).disposed(by: disposeBag)
    
    resetButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.isRuning.value = false
        self?.currentNumber.value = 0
        
        AudioPlayerManagr.sharedManager.palySoundEffect()
        
      }).disposed(by: disposeBag)
    }
}

