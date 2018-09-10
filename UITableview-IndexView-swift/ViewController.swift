//
//  ViewController.swift
//  UITableview-IndexView-swift
//
//  Created by ma c on 2018/9/7.
//  Copyright © 2018年 ma c. All rights reserved.
//

import UIKit
let NAV_HEIGHT : CGFloat = 64.0

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, IndexViewDelegate, IndexViewDataSource {
    
    

    var demoTableView = UITableView.init(frame: CGRect(x: 0, y: NAV_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAV_HEIGHT), style: .plain)
    let dataSourceArray = ["sdacb","asdd","asdf","卡地亚", "法兰克穆勒", "尊皇", "蒂芙尼", "艾米龙", "NOMOS", "依波路", "波尔", "帝舵", "名士", "芝柏", "积家", "尼芙尔", "sfgk", "dsfg", "拉芙兰瑞", "宝格丽", "古驰", "香奈儿", "迪奥", "雷达", "豪利时", "路易.威登", "蕾蒙威", "康斯登", "爱马仕", "昆仑", "斯沃琪", "WEMPE", "rsghj", "mshjk", "柏莱士", "hskll", "osplj", "帕玛强尼", "格拉苏蒂原创", "伯爵", "百达翡丽", "爱彼", "宝玑", "江诗丹顿", "宝珀", "理查德·米勒", "梵克雅宝", "罗杰杜彼", "萧邦", "百年灵", "宝齐莱", "瑞宝", "沛纳海", "宇舶", "真力时", "万国", "欧米茄", "劳力士", "朗格"]
    var searchResultDatabase = [String]()
    var indexView : IndexView?
    
    var brandArray = [Dictionary<String, Any>]()
    
    var isSearchMode = true
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.brandArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = self.brandArray[section];
        let array : [String] = dict["content"] as! [String]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && self.isSearchMode) {
            return 56
        }
        return 30
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        if section == 0 , self.isSearchMode {
            
            print(UIApplication.shared.keyWindow?.subviews )
//            for view in (UIApplication.shared.keyWindow?.subviews)!{
//                if view.isKind(of: UITransitionView.self){
//
//                }
//            }
            
            var headview : TableViewSearchHeaderView = TableViewSearchHeaderView.init(reuseIdentifier: "TableViewSearchHeaderView")
//            headview.letter = self.brandArray[section]["firstLetter"] as! String
            headview.resultSearchController.searchResultsUpdater = self
            headview.resultSearchController.searchBar.delegate = self
           
            return headview
        }else{
            
            var headview : TableViewHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "viewForHeaderInSection") as! TableViewHeaderView
            headview.letter = self.brandArray[section]["firstLetter"] as! String

            return headview
        }

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "IndexViewDataSource")
        let dict = self.brandArray[indexPath.section]
        let array : [String] = dict["content"] as! [String]
        //品牌
        let brandInfo = array[indexPath.row]
        cell.textLabel?.text = brandInfo
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.indexView?.tableView(tableView: tableView, willDisplayHeaderView: view, for: section)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.indexView?.tableView(tableView: tableView, didEndDisplayingHeaderView: view, for: section)
    }
    
    func selectedSectionIndexTitle(title: String, at index: Int) {
        if (self.isSearchMode && (index == 0)) {
            //搜索视图头视图(这里不能使用scrollToRowAtIndexPath，因为搜索组没有cell)
            self.demoTableView.setContentOffset(.zero, animated: false)
            return
        }
        self.demoTableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableViewScrollPosition.top, animated: false)
    }
    
    func addIndicatorView(view: UIView) {
        self.view.addSubview(view)
    }
    
    func sectionIndexTitles() -> Array<Any> {
        //搜索符号
        let resultArray = NSMutableArray.init(object: UITableViewIndexSearch)
        for dict in self.brandArray {
            let array : [String] = dict["content"] as! [String]
            let title = dict["firstLetter"]
            
            if (title) != nil ,array.count > 0{
                resultArray.add(title)
            }
        }
        return resultArray as! Array<Any>
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.indexView?.scrollViewDidScroll(scrollView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        //解析数据
        let tempBrandArray = NSMutableArray.init()
        for brandName in self.dataSourceArray {
            tempBrandArray.add(brandName as! String)
        }
        //获取拼音首字母
        let indexArray = (tempBrandArray as! Array<Any>).arrayWithPinYinFirstLetterFormat()
        self.brandArray = NSMutableArray.init(array: indexArray) as! [Dictionary<String, Any>]

        //添加搜索视图
        self.isSearchMode = true
        let searchDic = NSMutableDictionary.init()
        searchDic.setValue(NSMutableArray.init(), forKey: "content")
        searchDic.setValue("", forKey: "firstLetter")
        self.brandArray.insert(searchDic as! Dictionary<String, Any>, at: 0)

        //添加视图
        indexView = IndexView.init()
        
        demoTableView.delegate = self
        demoTableView.dataSource = self
        demoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "IndexViewDataSource")
        demoTableView.register(TableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: "viewForHeaderInSection")
        demoTableView.register(TableViewSearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "TableViewSearchHeaderView")
        indexView?.indexViewdelegate = self
        indexView?.indexViewdataSource = self
        indexView?.frame = CGRect(x:SCREEN_WIDTH - 30, y:NAV_HEIGHT, width:30, height:SCREEN_HEIGHT - NAV_HEIGHT)
        
        self.view.addSubview(demoTableView)
        self.view.addSubview(indexView!)
        //默认设置第一组
        self.indexView?.setSelectionIndex(index: 0)

        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController:UISearchResultsUpdating, UISearchBarDelegate{
    
    // MARK: - Search Actions
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        self.searchResultDatabase.removeAll()
       
        var searchResultArray = [String]()
        
       
        
        
        //        let objectification = Objectification(objects: searchResultArray,type: .values,propertieName:"name")
        //        let result = objectification.objects(contain: searchBar.text!)
        
//        let predicate = NSPredicate(format: "name CONTAINS[cd] %@",searchBar.text!)
        let result = self.dataSourceArray.searchWithString(string: searchBar.text!)
        let tempBrandArray = NSMutableArray.init()
        for brandName in result {
            tempBrandArray.add(brandName as! String)
        }
        let indexArray = (tempBrandArray as! Array<Any>).arrayWithPinYinFirstLetterFormat()
        self.brandArray.removeAll()
        self.brandArray = NSMutableArray.init(array: indexArray) as! [Dictionary<String, Any>]
        
        reloadSearchData()
       
    }
    
    func reloadSearchData()  {
        let searchDic = NSMutableDictionary.init()
        searchDic.setValue(NSMutableArray.init(), forKey: "content")
        searchDic.setValue("", forKey: "firstLetter")
        self.brandArray.insert(searchDic as! Dictionary<String, Any>, at: 0)
        self.demoTableView.reloadData()
        self.indexView?.reloadDataAndUI()
        self.indexView?.setSelectionIndex(index: 0)
    }
 
    
    open func updateSearchResults(for searchController: UISearchController)
    {
        for sousuo in searchController.searchBar.subviews {
            for view in sousuo.subviews {
                if (view.isKind(of: UIButton.self)){
                    let btn = view as! UIButton
//                    btn.setTitleColor(hexColor(hex: "cd2325"), for: .normal)
                }
            }
        }
        
      
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        let tempBrandArray = NSMutableArray.init()
        for brandName in self.dataSourceArray {
            tempBrandArray.add(brandName as! String)
        }
        let indexArray = (tempBrandArray as! Array<Any>).arrayWithPinYinFirstLetterFormat()
        self.brandArray.removeAll()
        self.brandArray = NSMutableArray.init(array: indexArray) as! [Dictionary<String, Any>]
        
        reloadSearchData()
       
    }
    
    
    
}
