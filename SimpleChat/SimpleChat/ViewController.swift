//
//  ViewController.swift
//  SimpleChat
//
//  Created by cano on 2018/04/21.
//  Copyright © 2018年 cano. All rights reserved.
//

import UIKit
import SocketIO
import RxSwift
import RxCocoa
import NSObject_Rx

class ViewController: UIViewController {

    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton:UIButton!
    @IBOutlet weak var sendTextField:UITextField!
    
    let manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [.log(true), .compress])
    var socket : SocketIOClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Socket 準備
        self.socket = manager.defaultSocket
        self.addSocketHandlers()
        socket?.connect()
        
        // キーボード上部UI
        self.sendTextField.setInputAccessoryView()
        
        // ボタン操作 テキストメッセージ送信
        self.sendButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.socket?.emit("chat message", with: [self.sendTextField.text!])
            self.sendTextField.text = ""
        }).disposed(by: rx.disposeBag)
    }
    
    /// Socket動作
    func addSocketHandlers() {
        // 接続
        self.socket?.on("connect") {data, ack in
            print("socket connected")
        }
        
        // テキストメッセージ受信
        self.socket?.on("chat message") {[unowned self] data, ack in
            if let value = data.first as? String {
                self.chatTextView.text = (self.chatTextView.text != "") ? self.chatTextView.text + "\n" + value : value
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UITextField {
    
    func setInputAccessoryView() {
        self.inputAccessoryView = self.generateInputAccessoryView()
    }
    
    // キーボード上部の完了ボタン
    func generateInputAccessoryView() -> UIView {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:nil)
        done.tintColor = .black
        toolbar.setItems([flexible, done], animated: true)
        
        done.rx.tap.subscribe(onNext: { [unowned self] in
            self.resignFirstResponder()
        }).disposed(by: rx.disposeBag)
        
        return toolbar
    }
}
