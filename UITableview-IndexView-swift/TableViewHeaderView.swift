//
//  TableViewHeaderView.swift
//  UITableview-IndexView-swift
//
//  Created by ma c on 2018/9/10.
//  Copyright © 2018年 ma c. All rights reserved.
//

import UIKit

class TableViewHeaderView: UITableViewHeaderFooterView {

    var firstLetterLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
//        label.textAlignment = .center
        return label
    }()
    var letter : String?{
        didSet{
            let size = (letter as! NSString).boundingRect(with: CGSize(width: SCREEN_WIDTH, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.firstLetterLabel.font], context: nil).size
            self.firstLetterLabel.text = letter
            self.firstLetterLabel.frame = CGRect(x: 16, y: (30.0 - size.height)/2.0, width: size.width, height: size.height)
            
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.firstLetterLabel)
        self.contentView.backgroundColor = UIColor.init(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

class TableViewSearchHeaderView: UITableViewHeaderFooterView {
    
    

    var resultSearchController : UISearchController =  {
        let controller = UISearchController(searchResultsController: nil)

        controller.dimsBackgroundDuringPresentation = true
        controller.hidesNavigationBarDuringPresentation = true
        controller.searchBar.sizeToFit()

        controller.searchBar.setBackgroundImage(UIImage.init(named: "searchBackground"), for: UIBarPosition(rawValue: 0)!, barMetrics: UIBarMetrics(rawValue: 0)!)

        return controller
    }()


    override init(reuseIdentifier: String?) {

        super.init(reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.resultSearchController.searchBar)
        self.contentView.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

