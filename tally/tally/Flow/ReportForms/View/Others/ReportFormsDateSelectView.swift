//
//  ReportFormsDateSelectView.swift
//  tally
//
//  Created by zykj on 2019/5/21.
//  Copyright © 2019 李志敬. All rights reserved.
//

import UIKit


class ReportFormsDateSelectView: UIView, UITableViewDelegate, UITableViewDataSource {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
   static let years: Int = 120

    
    
    
    //MARK: - Property
    
    let identifier: String = "identifier"
    var yearLabel: UILabel?
    var imageView: UIImageView?
    var dataArray: Array<Any>?
    var animatedflag: Bool = true
    var handler: ((NSInteger, NSInteger) ->Void)?
    var selectYearCallback: ((NSInteger, NSInteger)->Void)?
    
    
    var _year: NSInteger = 2019
    var year: NSInteger {
        set{
            _year = newValue
            self.yearLabel?.text = String(format: "%d年", _year)
            if self.handler != nil {
                self.handler?(newValue, self.month)
            }
        }
        get{
            return _year
        }
    }
    var _month: NSInteger = 5
    var month: NSInteger{
        set{
            _month = newValue
            self.handler?(self.year, newValue)
        }
        get{
            return _month
        }
    }
    
    //MARK: - Lazy
    
    lazy var tableView: UITableView = {
        let aTableView: UITableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        aTableView.backgroundColor = UIColor.clear
        aTableView.decelerationRate = UIScrollView.DecelerationRate.fast
        aTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        aTableView.showsHorizontalScrollIndicator = false
        aTableView.showsVerticalScrollIndicator = false
        aTableView.delegate = self
        aTableView.dataSource = self
        aTableView.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi * 0.5))
        aTableView.register(ReportFormsDateSelectTableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
        return aTableView
    }()
    
    //MARK: - Instance
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        loadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetupUI
    
    func setupUI() -> Void {
        
        self.yearLabel = UILabel.init()
        self.yearLabel?.isUserInteractionEnabled = true
        self.yearLabel?.text = ""
        self.yearLabel?.font = UIFont.init(name: "PingFang SC-Regular", size: 14)
        self.yearLabel?.textColor = UIColor.white
        self.addSubview(self.yearLabel ?? UILabel.init())
        self.yearLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo(15)
            make.top.equalTo(0)
            make.height.equalTo(32)
        })
        
        self.imageView = UIImageView.init(image: UIImage.init(named: "下箭头-白"))
        self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        self.addSubview(self.imageView ?? UIImageView.init())
        self.imageView?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.yearLabel?.snp.right ?? 0)
            make.width.height.equalTo(15)
            make.centerY.equalTo(self.yearLabel ?? self)
        })
        
        let view: UIView = UIView.init()
        self.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.equalTo(self.imageView?.snp.right ?? 0).offset(10)
            make.right.equalTo(-10)
            make.top.bottom.equalTo(0)
        }
        
        view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.width.equalTo(view.snp.height)
            make.height.equalTo(view.snp.width)
            make.centerY.centerX.equalTo(view)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAction(tap:)))
        self.yearLabel?.addGestureRecognizer(tap)
        
    }
    
    //MARK: - LoadData
    
    private func loadData() -> Void {
        
        self.dataArray = ["12","11","10","9","8","7","6", "5","4","3","2","1"]

        let yearString: String = CalendarHelper.nowDateString(dateFormat: "yyyy")
        self.year = NSInteger.init(yearString) ?? 0
        let monthString = CalendarHelper.nowDateString(dateFormat: "MM")
        self.month = NSInteger(monthString) ?? 0
        self.tableView.reloadData()

        let indexPath: IndexPath = IndexPath.init(row: 2, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)

    }
    
    //MARK: - Methods
    
    func setDate(year: NSInteger, month: NSInteger) -> Void {
        
        if month == 0{
            
            self.tableView.isHidden = true
            _month = month
            self.year = year
            
        }else{
            self.tableView.isHidden = false
            
            let nowYear: String = CalendarHelper.nowDateString(dateFormat: "yyyy")
            let noweYearValue: NSInteger = NSInteger.init(nowYear) ?? 1
            let section: NSInteger = noweYearValue-year
            if section >= 0{
                
                var row: NSInteger?
                if section > 0{
                    row = 12 - month
                }else{
                    let rowNum = self.tableView.numberOfRows(inSection: 0)
                    if month > rowNum - 2{
                        row = rowNum - 2
                    }else{
                        row = rowNum - month
                    }
                }
                let indexPath: IndexPath = IndexPath.init(row: row ?? 0, section: section)
                
                self.animatedflag = false
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
                self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.none, animated: false)
                self.setYearAndMonth(by: indexPath)
                self.setTableContentOffset(indexPath: indexPath, animation: true) {
                    self.animatedflag = true
                }
                
            }
            
        }
        
        
        
    }
    
    func selectYearCallback(callback: @escaping (NSInteger, NSInteger)->Void) -> Void {
        self.selectYearCallback = callback;
    }
    
    func selectedDateCallback(callback: @escaping (NSInteger, NSInteger)->Void) -> Void {
        self.handler = callback;
    }
    
    /*
     *  只实用于手动点击跳动，不可使用于代码手动设置，因为使用了transform属性，偏移量有很大误差，
     *  使用系统方法进行偏移，才能校正偏移误差
     */
    private func manualSelectedSetupOffset(indexPath: IndexPath) -> Void {
        self.animatedflag = false
        self.setYearAndMonth(by: indexPath)
        self.setTableContentOffset(indexPath: indexPath, animation: true) {
            self.animatedflag = true
        }
    }
    
    @objc private func tapGestureAction(tap: UITapGestureRecognizer){
        self.tableView.isHidden = true
        if self.selectYearCallback != nil{
            self.selectYearCallback?(self.year, self.month);
        }
    }
    
    private func setYearAndMonth(by indexPath: IndexPath) -> Void {
        if indexPath.section == 0{
            let monthString = CalendarHelper.nowDateString(dateFormat: "MM")
            let month: NSInteger = NSInteger(monthString) ?? 0
            self.month = NSInteger(self.dataArray?[indexPath.row + 12 - month - 2] as! String)!
        }else{
            self.month = NSInteger.init(self.dataArray?[indexPath.row] as! String) ?? 0
        }
        
        let yearString: String = CalendarHelper.nowDateString(dateFormat: "yyyy")
        self.year = NSInteger.init(yearString) ?? 0
        self.year -= indexPath.section
    }

   private func setTableContentOffset(indexPath:IndexPath, animation: Bool, complete: @escaping (()->Void)) -> Void {
        
        var time: CGFloat = 0.00
        if animation {
            time = 0.2
        }
        
//        let height: CGFloat = 40
    
        UIView.animate(withDuration: TimeInterval(time), animations: {
            /*
            let offsetCount: NSInteger
            if indexPath.section == 0{
                offsetCount = indexPath.row - 2
            }else{
                let rowCount: NSInteger = self.tableView.numberOfRows(inSection: 0)
                offsetCount = rowCount + 12 * (indexPath.section - 1) + indexPath.row - 2
            }
            self.tableView.setContentOffset(CGPoint.init(x: 0, y:  height * CGFloat(offsetCount)), animated: false)
            */
            
            let cell: UITableViewCell = self.tableView.cellForRow(at: indexPath) ?? UITableViewCell.init()
            
            if  self.tableView.visibleCells.contains(cell){
                
                let rect: CGRect = cell.superview?.convert(cell.frame, to: self.tableView.superview) ?? CGRect.zero
                let width = self.tableView.superview?.frame.width
                
                let  offsetY: CGFloat =  self.tableView.contentOffset.y + (width ?? 0) - rect.maxX - 40 * 2
                self.tableView.setContentOffset(CGPoint.init(x: 0, y: offsetY), animated: false)
            }
            
            
        }) { (flag) in
            
            complete()
            
        }
        
    }

    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.animatedflag == false{
            return
        }
        
        if self.tableView.visibleCells.count > 2 {
            let cell: UITableViewCell = self.tableView.visibleCells[2]
            let indexPath: IndexPath = tableView.indexPath(for: cell) ?? IndexPath.init()
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
            self.setYearAndMonth(by: indexPath)
        }
    
        
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.manualSelectedSetupOffset(indexPath: indexPath)
        
    }
    

    
    //MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ReportFormsDateSelectView.years
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            let monthString = CalendarHelper.nowDateString(dateFormat: "MM")
            let month: NSInteger = NSInteger(monthString) ?? 0
            return month + 2
        }
        return self.dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ReportFormsDateSelectTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ReportFormsDateSelectTableViewCell
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 1{
                cell.label?.text = ""
                cell.isUserInteractionEnabled = false
            }else{
                let monthString = CalendarHelper.nowDateString(dateFormat: "MM")
                let month: NSInteger = NSInteger(monthString) ?? 0
                cell.label?.text = (self.dataArray?[indexPath.row + 12 - month - 2] as! String).appending("月")
                cell.isUserInteractionEnabled = true
            }

        }else{
            cell.label?.text = (self.dataArray?[indexPath.row] as! String).appending("月")
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    

}
