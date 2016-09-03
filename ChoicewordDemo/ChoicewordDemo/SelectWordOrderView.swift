//
//  SelectWordOrderView.swift
//  ChoicewordDemo
//
//  Created by Chakery on 16/9/2.
//  Copyright © 2016年 Chakery. All rights reserved.
//

import UIKit

private let Margin: CGFloat = 10 //间距
private let FontSize: CGFloat = 14 //字体大小
private let ItemHeight: CGFloat = 30 //item高度
private let WordMarginTop: CGFloat = 40 //单词跟横向的top间距

private let ConfirmButtonHeight: CGFloat = 44 //确定按钮的高度
private let ConfirmButtonBackgroundColor = UIColor(red: 248/255.0, green: 78/255.0, blue: 78/255.0, alpha: 1)

private let LineColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
private let ButtonBackgroundColor = UIColor(red: 29/255.0, green: 142/255.0, blue: 240/255.0, alpha: 1)
private let ButtonBackgroundViewColor = UIColor(red: 191.0/255.0, green: 191.0/255.0, blue: 191.0/255.0, alpha: 1)
private let ButtonTextColor = UIColor(white: 1, alpha: 1)

public class SelectWordOrderView: UIView {
    private var confirmButton: UIButton! //确定按钮
    private var words: [String] //单词
    private var wordsLength: [String: CGFloat] //单词对应的宽度
    private var totalLength: CGFloat //所有单词组合在一起的长度
    
    private var wordTopLayout: CGFloat //单词顶部的约束
    private var didSelectedWords: [WordButton] //被选中的按钮
    private var defaultWords: [WordButton] //默认的按钮
    private var backgroundViews: [CALayer] //背景图
    
    private var confirmCallBack: ([String] -> Void)?
    
    
    public init(words: [String]) {
        self.words = words
        self.wordsLength = [:]
        self.totalLength = 0.0
        self.wordTopLayout = 0.0
        self.didSelectedWords = []
        self.defaultWords = []
        self.backgroundViews = []
        super.init(frame: CGRectZero)
        self.totalLength = countLength(words, margin: Margin, fontSize: FontSize)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 点击之后的回调
    public func confirmButtonCallBack(callBack: [String] -> Void) {
        self.confirmCallBack = callBack
    }
    
    /// 统计单词的总长度（包括间距）
    private func countLength(words:[String], margin: CGFloat, fontSize: CGFloat) -> CGFloat {
        var totalLength: CGFloat = margin
        wordsLength.removeAll()
        (0..<words.count).forEach { i in
            let wordString = words[i]
            let word = NSString(string: wordString)
            let size = word.sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(fontSize)])
            let wordWidth = size.width + margin * 2
            totalLength += wordWidth
            wordsLength[wordString] = wordWidth
        }
        return totalLength
    }
    
    /// 绘制确定按钮
    private func setupConfirmButton(topView: WordButton) {
        let topLayout = topView.frame.origin.y + topView.bounds.height + WordMarginTop
        
        confirmButton = UIButton()
        confirmButton.setTitle("确定", forState: .Normal)
        confirmButton.setTitleColor(UIColor(white: 1, alpha: 1), forState: .Normal)
        confirmButton.backgroundColor = ConfirmButtonBackgroundColor
        confirmButton.addTarget(self, action: #selector(SelectWordOrderView.confirmButtonEvent(_:)), forControlEvents: .TouchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(confirmButton)
        
        addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200))
        addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: topLayout))
        //addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -Margin))
        addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 44))
    }
    
    
    /// 确定按钮点击事件
    @objc private func confirmButtonEvent(btn: UIButton) {
        var words: [String] = []
        didSelectedWords.forEach {
            if let text = $0.titleLabel?.text {
                words.append(text)
            }
        }
        confirmCallBack?(words)
    }
    
    /// 绘制横线
    private func drawLine(number: Int) {
        (0..<number).forEach { i in
            let lineLayer = CALayer()
            let x: CGFloat = 0
            let y: CGFloat = (Margin + ItemHeight) * CGFloat(i + 1)
            let w: CGFloat = frame.size.width
            let h: CGFloat = 1
            lineLayer.frame = CGRect(x: x, y: y, width: w, height: h)
            lineLayer.backgroundColor = LineColor.CGColor
            layer.addSublayer(lineLayer)
            wordTopLayout = y + h
        }
    }
    
    /// 绘制单词
    private func drawWords(datasource datasource: [String], startY: CGFloat) {
        (0..<datasource.count).forEach { i in
            let word = datasource[i]
            let wordWidth = wordsLength[word]!

            let x: CGFloat = 0
            let y: CGFloat = 0
            let w: CGFloat = wordWidth
            let h: CGFloat = ItemHeight
            let rect = CGRect(x: x, y: y, width: w, height: h)
            
            // draw background view
            let bgLayer = CALayer()
            bgLayer.frame = rect
            bgLayer.backgroundColor = ButtonBackgroundViewColor.CGColor
            self.layer.addSublayer(bgLayer)
            backgroundViews.append(bgLayer)
            
            // draw btn
            let btn = WordButton(frame: rect)
            btn.tag = i
            btn.setTitle(word, forState: .Normal)
            btn.backgroundColor = ButtonBackgroundColor
            btn.setTitleColor(ButtonTextColor, forState: .Normal)
            btn.addTarget(self, action: #selector(SelectWordOrderView.wordButtonEvent(_:)), forControlEvents: .TouchUpInside)
            self.addSubview(btn)
            defaultWords.append(btn)
        }
        resetWordButtonPosition(datasource: defaultWords, backgroundViews: backgroundViews, startY: startY)
    }
    
    /// 单词点击事件
    @objc private func wordButtonEvent(btn: WordButton) {
        btn.didSelected = !btn.didSelected
        if btn.didSelected {
            didSelectedWords.append(btn)
        } else {
            btn.positionAnimations(btn.defaultFrame)
            didSelectedWords.removeObject(btn)
        }
        resetWordButtonPosition(datasource: didSelectedWords, startY: Margin)
    }
    
    /// 改变单词的位置
    private func resetWordButtonPosition(datasource datasource: [WordButton], backgroundViews: [CALayer]? = nil, startY: CGFloat) {
        var tempX: CGFloat = Margin //如果这个值大于当前view的宽度，则换行显示
        var tempY: CGFloat = startY //记录当前的y坐标
        (0..<datasource.count).forEach { i in
            let btn = datasource[i]
            if (tempX + btn.bounds.width) > frame.size.width {
                tempX = Margin
                tempY += (ItemHeight + Margin)
            }
            
            let x: CGFloat = tempX
            let y: CGFloat = tempY
            let rect = CGRect(origin: CGPoint(x: x, y: y), size: btn.bounds.size)
            
            if let bgLayer = backgroundViews?[i] {
                bgLayer.frame = rect
                btn.frame = rect
            } else {
                UIView.animateWithDuration(0.3) {
                    btn.frame = rect
                }
            }
            
            if btn.didSelected {
                btn.selectedFrame = rect
            } else {
                btn.defaultFrame = rect
            }
            
            tempX += (btn.bounds.width + Margin)
            
            // 第一次绘制到最后一个按钮时，绘制确定按钮
            if backgroundViews != nil && i == datasource.count - 1 {
                setupConfirmButton(btn)
            }
        }
    }
    
    /// 确定frame
    public override func layoutSubviews() {
        super.layoutSubviews()
        let remainder = totalLength % frame.size.width == 0 ? 0 : 1
        let num = lroundf(Float(totalLength / frame.size.width)) + remainder
        drawLine(num)
        drawWords(datasource: words, startY: wordTopLayout + WordMarginTop)
    }
}



private class WordButton: UIButton {
    /// 是否被选中
    var didSelected: Bool
    /// 原来的坐标
    var defaultFrame: CGRect!
    /// 选中之后的坐标
    var selectedFrame: CGRect!
    
    override init(frame: CGRect) {
        self.defaultFrame = frame
        self.didSelected = false
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func positionAnimations(frame: CGRect) {
        UIView.animateWithDuration(0.3) {
            self.frame = frame
        }
    }
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    /// Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}










