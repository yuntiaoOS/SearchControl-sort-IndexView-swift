//
//  IndexView.swift
//  UITableview-IndexView-swift
//
//  Created by ma c on 2018/9/7.
//  Copyright © 2018年 ma c. All rights reserved.
//

import UIKit


let SCREEN_WIDTH =  UIScreen.main.bounds.size.width
let SCREEN_HEIGHT =  UIScreen.main.bounds.size.height
@objc
protocol IndexViewDelegate:NSObjectProtocol {
    /** 当前选中下标 */
    @objc func selectedSectionIndexTitle(title:String,at index:Int)
    /** 添加指示器视图 */
    @objc func addIndicatorView(view:UIView)
}
@objc
protocol IndexViewDataSource:NSObjectProtocol {
    /** 组标题数组 */
    @objc func sectionIndexTitles() -> Array<Any>
  
}

class IndexView: UIControl {

    weak var indexViewdelegate : IndexViewDelegate?
    weak var indexViewdataSource : IndexViewDataSource?
    
    var titleFontSize : CGFloat?
    var marginRight :CGFloat?
    var titleSpace :CGFloat?
    var indicatorMarginRight :CGFloat = 1.0
    var titleColor :UIColor?
    
    var vibrationOn :Bool = true
    var searchOn :Bool?
    
    private var indicatorView :SectionIndicatorView?
    /**< 组标题数组 */
    private var indexItems :Array<Any>?
    /**< 标题视图数组 */
    private var itemsViewArray :Array<Any> = NSMutableArray.init() as! Array<Any>
    
    private var newIndex :Int = 0
    private var oldIndex :Int = Int.max
    
    /**< 当前选中下标 */
    private var selectedIndex :Int? {
        didSet{
            
            //下标
            newIndex = selectedIndex!
            
            if oldValue != nil {
                oldIndex = oldValue as! Int
            }
            
            //处理新旧item
            if ((oldIndex > 0 || oldIndex == 0) && oldIndex < (self.itemsViewArray.count)) {
                let oldItemLabel:UILabel = self.itemsViewArray[oldIndex] as! UILabel
                oldItemLabel.textColor = self.titleColor;
                self.selectedImageView.frame = .zero;
            }
            if ((newIndex > 0 || newIndex == 0) && newIndex < (self.itemsViewArray.count)) {
                
                let newItemLabel:UILabel = self.itemsViewArray[newIndex] as! UILabel
                newItemLabel.textColor = .white
                //处理选中圆形
                //圆直径
                var isLetter = true       //是否是字母
               
    
                for (index,value) in (newItemLabel.text?.enumerated())!{
                    if index == 0{
                        let firstLetter = value.description
                        
                        if (!(firstLetter >= "a" && firstLetter <= "z") || !(firstLetter >= "A" && firstLetter <= "Z") || newItemLabel.text == "#" ){
                            let diameter:CGFloat = ((self.itemMaxSize!.width > self.itemMaxSize!.height) ? self.itemMaxSize!.width : self.itemMaxSize!.height) + self.titleSpace!
                            self.selectedImageView.frame = CGRect(x:0, y:0, width:diameter, height:diameter)
                            self.selectedImageView.center = newItemLabel.center
                            self.selectedImageView.layer.mask = self.imageMaskLayer(bounds: (self.selectedImageView.bounds), radiu: diameter/2.0)
                            self.insertSubview(self.selectedImageView, belowSubview: newItemLabel)
                        } else {
                            isLetter = false
                        }
                        
                    }else{
                        break
                    }
                    
                }

                //回调代理方法
                if (self.isCallback! && (self.indexViewdelegate != nil) && (self.indexViewdelegate?.responds(to: #selector(self.indexViewdelegate?.selectedSectionIndexTitle(title:at:))))!) {
                    self.indexViewdelegate?.selectedSectionIndexTitle(title: self.indexItems![newIndex] as! String, at: newIndex)
                    
                    if isLetter,newIndex != 0 {
                        //只有手势滑动，才会触发指示器视图
                        if (!(self.indicatorView != nil)) {
                            self.indicatorView = SectionIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                        }
                        self.indicatorView?.alpha = 1.0
                        self.indicatorView?.set(origin: CGPoint(x: SCREEN_WIDTH - self.marginRight! - self.titleFontSize! - 10 - self.indicatorMarginRight, y: newItemLabel.center.y + self.frame.origin.y), title: newItemLabel.text!)
                        //将指示器视图添加到scrollView的父视图上
                        if ((self.indexViewdelegate != nil) && (self.indexViewdelegate?.responds(to: #selector(self.indexViewdelegate?.addIndicatorView(view:))))!){
                            self.indexViewdelegate?.addIndicatorView(view: self.indicatorView!)
                        }
                    }
                    
                }
                
            }
            
//            selectedIndex = newValue
        }
        
    }
    /**< Y坐标最小值 */
    private var minY :CGFloat?
    /**< Y坐标最大值 */
    private var maxY :CGFloat?
    /**< item大小，参照W大小设置 */
    private var itemMaxSize :CGSize?
    /**< 当前选中item的背景圆 */
    private var selectedImageView :UIImageView = {
       
        let selectedImageView1 = UIImageView.init()
        selectedImageView1.backgroundColor = UIColor.init(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        
        return selectedImageView1
        
    }()
    /**< 是否需要调用代理方法，如果是scrollView自带的滚动，则不需要触发代理方法，如果是滑动指示器视图，则触发代理方法 */
    private var isCallback :Bool?
    /**< 是否显示指示器，只有触摸标题，才显示指示器 */
    private var isShowIndicator :Bool?
    /**< 是否是上拉滚动 */
    private var isUpScroll :Bool?
    /**< 是否第一次加载tableView */
    private var isFirstLoad :Bool?
    /**< 滚动的偏移量 */
    private var oldY :CGFloat = 0.0
    /**< 是否允许改变当前组 */
    private var isAllowedChange :Bool?
    /**< 震动反馈  */
    private var generator :UIImpactFeedbackGenerator?
    
    func setSelectionIndex(index:Int)  {
        if (index >= 0 && index <= (self.indexItems?.count)!) {
            //改变组下标
            self.isCallback = false
            self.selectedIndex = index;
        }
    }
    func tableView(tableView:UITableView,willDisplayHeaderView view:UIView,for section:Int)  {
        if(self.isAllowedChange! && !self.isUpScroll! && !self.isFirstLoad!) {
            //最上面组头（不一定是第一个组头，指最近刚被顶出去的组头）又被拉回来
            self.setSelectionIndex(index: section)  //section
        }
    }
    func tableView(tableView:UITableView,didEndDisplayingHeaderView view:UIView,for section:Int)  {
        if (self.isAllowedChange! && !self.isFirstLoad! && self.isUpScroll!) {
            //最上面的组头被顶出去
            self.setSelectionIndex(index: section + 1) //section + 1
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     
        if (scrollView.contentOffset.y > self.oldY) {
            self.isUpScroll = true      // 上滑
        }
        else {
            self.isUpScroll = false       // 下滑
        }
        self.isFirstLoad = false
        
        self.oldY = scrollView.contentOffset.y
    }


    func reloadDataAndUI()  {
        
        for uiv in self.subviews {
            uiv.removeFromSuperview()
        }
        itemsViewArray = NSMutableArray.init() as! Array<Any> 
        self.isShowIndicator = false
        //获取标题组
        if ((self.indexViewdataSource != nil) && (self.indexViewdataSource?.responds(to: #selector(self.indexViewdataSource?.sectionIndexTitles)))!) {
            self.indexItems = self.indexViewdataSource?.sectionIndexTitles()
            if (self.indexItems?.count == 0) {
                return
            }
        }
        else {
            return
        }
        //初始化属性设置
        self.attributeSettings()
        //初始化title
        self.initialiseAllTitles()
    }
    
    internal override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.isShowIndicator = false
        //获取标题组
        if ((self.indexViewdataSource != nil) && (self.indexViewdataSource?.responds(to: #selector(self.indexViewdataSource?.sectionIndexTitles)))!) {
            self.indexItems = self.indexViewdataSource?.sectionIndexTitles()
            if (self.indexItems?.count == 0) {
                return
            }
        }
        else {
            return
        }
        //初始化属性设置
       self.attributeSettings()
        //初始化title
        self.initialiseAllTitles()
    }
    
    private  func attributeSettings()  {
        //文字大小
//        if (self.titleFontSize == 0) {
            self.titleFontSize = 10
//        }
        //字体颜色
//        if (!(self.titleColor != nil)) {
            self.titleColor = UIColor.init(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
//        }
        //右边距
//        if (self.marginRight == 0) {
            self.marginRight = 7
//        }
        //文字间距
//        if (self.titleSpace == 0) {
            self.titleSpace = 4
//        }
        
        //默认就允许滚动改变组
        self.isAllowedChange = true
        
        self.isFirstLoad = true
        
        self.isUpScroll = false
    }
    
    private func initialiseAllTitles()  {
        //高度是否符合
        let totalHeight:CGFloat = (CGFloat((self.indexItems?.count)!) * self.titleFontSize!) + (CGFloat((self.indexItems?.count)! + 1) * self.titleSpace!)
        if (self.frame.height < totalHeight) {
            print("View height is not enough");
            return;
        }
        //宽度是否符合
        let  totalWidth:CGFloat = self.titleFontSize! + self.marginRight!
        if ((self.frame).width < totalWidth) {
            print("View width is not enough")
            return
        }

        //设置Y坐标最小值
        self.minY = ((self.frame.height) - totalHeight)/2.0
        var  startY:CGFloat  = self.minY!  + self.titleSpace!
        //以 'W' 字母为标准作为其他字母的标准宽高
        self.itemMaxSize = ( "W" as!NSString).boundingRect(with: CGSize(width: SCREEN_WIDTH, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: self.titleFontSize!)], context: nil).size
        //标题视图布局
        for i in 0..<(self.indexItems?.count)! {
            let title :String = self.indexItems![i] as! String
            let itemLabel:UILabel = UILabel.init(frame: CGRect(x: self.frame.width - self.marginRight! - self.titleFontSize!, y: startY, width: self.itemMaxSize!.width, height: self.itemMaxSize!.height))
            
            //是否有搜索
            if (title == UITableViewIndexSearch) {
                itemLabel.text = nil;
                let attch:NSTextAttachment = NSTextAttachment.init()
                //定义图片内容及位置和大小
                attch.image = UIImage.init(named: "icon_user_search")
                attch.bounds = CGRect(x:0, y:0, width:(self.itemMaxSize?.height)! - 2, height:(self.itemMaxSize?.height)! - 2);
                let attri : NSAttributedString = NSAttributedString.init(attachment: attch)
                itemLabel.attributedText = attri
            } else {
                itemLabel.font = UIFont.boldSystemFont(ofSize: self.titleFontSize!)
                itemLabel.textColor = self.titleColor
                itemLabel.text = title
                itemLabel.textAlignment = .center
            }
            
            self.itemsViewArray.append(itemLabel)
            self.addSubview(itemLabel)
            //重新计算start Y
            startY = startY + (self.itemMaxSize?.height)! + self.titleSpace!
        }
        //设置Y坐标最大值
        self.maxY = startY;
    }
    
    internal override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let  location:CGPoint = touch.location(in: self)
        //滑动期间不允许scrollview改变组
        self.isAllowedChange = false
        self.selectedIndexByPoint(location: location)
        
      
        if (self.vibrationOn){
            self.generator = UIImpactFeedbackGenerator.init(style: .light)
        }
        
      
        
        return true
    }
    
    internal override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        self.selectedIndexByPoint(location: location)
        return true
    }
    
    internal override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        let location = touch?.location(in: self)
        if (((location?.y)! - self.minY!) < 0 || ((location?.y)! -  self.maxY!) > 0) {
            return
        }
        
        //重新计算坐标
        self.selectedIndexByPoint(location: location!)
        
        //判断当前是否是搜索，如果不是搜索才进行动画
        var isSearch = false
        if ((self.indexItems?.count)! > 0) {
            let firstTitle : String = self.indexItems![self.selectedIndex!] as! String
            if (firstTitle == UITableViewIndexSearch) {
                isSearch = true
            }
        }
        if (!isSearch) {
            self.animationView(view: self.indicatorView!)
        }
        
        //滑动结束后，允许scrollview改变组
        self.isAllowedChange = true
        
        self.generator = nil;
    }
    
    internal override func cancelTracking(with event: UIEvent?) {
        //只有当指示视图在视图上时，才能进行动画
        if ((self.indicatorView?.superview) != nil) {
           self.animationView(view: self.indicatorView!)
        }
        //滑动结束后，允许scrollview改变组
        self.isAllowedChange = true
        
        self.generator = nil
    }
    
    internal override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.cancelTracking(with: event)
    }
    
    private func animationView(view:UIView) {
        //即将开始进行动画前，判断指示器视图是否已经添加到父视图上
        if (!(self.indicatorView!.superview != nil)) {
            if ((self.indexViewdelegate != nil) && (self.indexViewdelegate?.responds(to: #selector(self.indexViewdelegate?.addIndicatorView(view:))))!){
                self.indexViewdelegate?.addIndicatorView(view: self.indicatorView!)
            }
        }
        
        view.alpha = 1.0;
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 0
        }, completion: { (finished) in
            //视图不移除，保证视图在连续点击时，不会出现瞬间消失的情况
        })
    }
    
    private func selectedIndexByPoint(location:CGPoint) {
        if (location.y >= self.minY! && location.y <= self.maxY!) {
            //计算下标
            let offsetY = location.y - self.minY! - (self.titleSpace! / 2.0)
            //单位高
            let item = (self.itemMaxSize?.height)! + self.titleSpace!;
            //计算当前下标
            let index = (offsetY / item) ;//+ ((offsetY % item == 0)?0:1) - 1;
            
            if (index != CGFloat(self.selectedIndex!)  && index < CGFloat((self.indexItems?.count)!) && index >= 0) {
                self.isCallback = true
                self.selectedIndex = Int(index)
                
                if (self.vibrationOn) {

                    self.generator?.prepare()
                    self.generator?.impactOccurred()
                    
                }
                
            }
        }
    }
    
    func imageMaskLayer(bounds:CGRect,radiu:CGFloat) -> CAShapeLayer {
        let maskPath:UIBezierPath  = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: UIRectCorner.allCorners , cornerRadii: CGSize(width:radiu,height: radiu))
        let maskLayer:CAShapeLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        return maskLayer
    }
    
}
extension IndexView: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
    
    
}
