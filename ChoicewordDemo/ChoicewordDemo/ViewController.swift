//
//  ViewController.swift
//  ChoicewordDemo
//
//  Created by Chakery on 16/9/2.
//  Copyright © 2016年 Chakery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let words = ["种","年","后","。","棵","的","在","时","是","十","前","，","而","间","是","现","最","好","树","一"]
        
        let v = SelectWordOrderView(words: words)
        v.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.confirmButtonCallBack { words in
            print(words)
        }
        view.addSubview(v)
        
        let hLayout = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v]-0-|", options: [], metrics: nil, views: ["v":v])
        let vLayout = NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[v(370)]", options: [], metrics: nil, views: ["v":v])
        view.addConstraints(hLayout)
        view.addConstraints(vLayout)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

