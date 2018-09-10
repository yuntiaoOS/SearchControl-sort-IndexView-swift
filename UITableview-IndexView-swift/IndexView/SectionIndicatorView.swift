//
//  SectionIndicatorView.swift
//  UITableview-IndexView-swift
//
//  Created by ma c on 2018/9/7.
//  Copyright © 2018年 ma c. All rights reserved.
//

import UIKit

class SectionIndicatorView: UIView {

    private var indicatorView : UIImageView?
    private var titleLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.indicatorView = UIImageView.init(frame: self.bounds)
        self.indicatorView?.image = UIImage.init(named: "index_indicator")
        self.indicatorView?.transform = CGAffineTransform.init(rotationAngle: -90.0*CGFloat.pi/180.0)
        self.addSubview(self.indicatorView!)
        
        self.titleLabel = UILabel.init(frame: self.bounds)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.textColor = .white
        self.addSubview(self.titleLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(origin:CGPoint,title:String) {
        self.frame = CGRect(x: origin.x - self.frame.size.width, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        var center: CGPoint = self.center
        center.y = origin.y
        self.center = center
        self.titleLabel?.text = title
    }

}

extension String{
    func getFirstLetter() -> String {
        // 注意,这里一定要转换成可变字符串
        let mutableString = NSMutableString.init(string: self)
        // 将中文转换成带声调的拼音
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        // 去掉声调(用此方法大大提高遍历的速度)
        let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
        // 将拼音首字母装换成大写
        let strPinYin = polyphoneStringHandle(nameString: self, pinyinString: pinyinString).uppercased()
        // 截取大写首字母
        let firstString = strPinYin.substring(to: strPinYin.index(strPinYin.startIndex, offsetBy:1))
        // 判断姓名首位是否为大写字母
        let regexA = "^[A-Z]$"
        let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
        return predA.evaluate(with: firstString) ? firstString : "#"
    }
    
    /// 多音字处理
    func polyphoneStringHandle(nameString:String, pinyinString:String) -> String {
        if nameString.hasPrefix("长") {return "chang"}
        if nameString.hasPrefix("沈") {return "shen"}
        if nameString.hasPrefix("厦") {return "xia"}
        if nameString.hasPrefix("地") {return "di"}
        if nameString.hasPrefix("重") {return "chong"}
        
        return pinyinString;
    }
}

extension Array{
    func arrayWithPinYinFirstLetterFormat() -> NSMutableArray {
        var nameKeys : [String] = [String]()
        var addressBookDict = [String:[String]]()
        var returnDic : NSMutableArray = NSMutableArray.init()
        
        for letterString in self{
            let firstLetterString = (letterString as! String).getFirstLetter()
            
            if addressBookDict[firstLetterString] != nil {
                // swift的字典,如果对应的key在字典中没有,则会新增
                addressBookDict[firstLetterString]?.append(letterString as! String)
                
            } else {
                var arrGroupNames = [String]()
                arrGroupNames.append(letterString as! String)
                addressBookDict[firstLetterString] = arrGroupNames as! [String]
            }
        }
        nameKeys = addressBookDict.keys.sorted()
        
        for value in nameKeys{
           
            let searchDic = NSMutableDictionary.init()
            searchDic.setValue(addressBookDict[value], forKey: "content")
            searchDic.setValue(value, forKey: "firstLetter")
            returnDic.add(searchDic)
        }
        
        
        return returnDic
        
    }
    
    func searchWithString(string:String) -> [String] {
        let predicate = NSPredicate(format: "SELF CONTAINS[cd] %@", string)
        var selectSection : [String] = [String]()

      
        return self.filter { predicate.evaluate(with: $0) } as! [String]
        

    }
}
