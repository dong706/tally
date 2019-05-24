//
//  ReportFormsViewController.swift
//  tally
//
//  Created by zykj on 2019/5/15.
//  Copyright © 2019 李志敬. All rights reserved.
//

import UIKit

class ReportFormsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum SummaryType {
        case month
        case year
    }
    
    enum TallyType {
        case monthlySpending
        case yearlySpending
        case monthlyIncome
        case yearlyIncome
    }
    
    //MARK: - Property
    let identifier: String = "identifier"
    var reportFormsView: ReportFormsView? = nil
    var date: String{
        get{
            return  String(format: "%d%02d", self.dateSelectView.year, self.dateSelectView.month)
        }
    }
    var type: TallyType = TallyType.monthlySpending
    var summaryType: SummaryType = SummaryType.month
    var list: Array<ReportFormsModel> = Array.init()

    
    //MARK: - Lazy
    
    lazy var spendingSelectView: SelectView = {
        let selectView: SelectView = SelectView.init()
        selectView.type = SelectView.SelectType.spending
        selectView.isSelected = true
        selectView.titleLabel.text = "月支出"
        selectView.amountLabel.text = "￥0.00"
        return selectView
    }()
    
    lazy var incomeSelectView: SelectView = {
        let selectView: SelectView = SelectView.init()
        selectView.type = SelectView.SelectType.income
        selectView.titleLabel.text = "月收入"
        selectView.amountLabel.text = "￥0.00"
        return selectView
    }()

    lazy var dateSelectView: ReportFormsDateSelectView = {
        let aDateSelectView: ReportFormsDateSelectView = ReportFormsDateSelectView.init()
        return aDateSelectView
    }()
    
    lazy var tableView: UITableView = {
        
        let aTableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        aTableView.backgroundColor = UIColor.clear
        aTableView.delegate = self
        aTableView.dataSource = self
        
        aTableView.register(ReportFormsTableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
        
        let headerView = UIView.init()
        headerView.backgroundColor = UIColor.clear
        headerView.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 350)
        aTableView.tableHeaderView = headerView
        aTableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 30))
        
        let formsView: UIView = UIView.init()
        formsView.backgroundColor = UIColor.white
        formsView.layer.cornerRadius = 4
        formsView.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        formsView.layer.shadowColor = UIColor.init(red: 215 / 255.0, green: 215 / 255.0, blue: 215 / 255.0, alpha: 1.0).cgColor
        formsView.layer.shadowOpacity = 1
        headerView.addSubview(formsView)
        formsView.frame = CGRect.init(x: 15, y: 0, width: kScreenWidth - 15 * 2, height: headerView.bounds.height - 15)

        self.reportFormsView = ReportFormsView.init(frame: CGRect.init(x: 0, y: 80, width: formsView.frame.width, height: formsView.frame.height - 80 - 10))
        formsView.addSubview(self.reportFormsView ?? UIView.init())
        
        formsView.addSubview(self.spendingSelectView)
        self.spendingSelectView.frame = CGRect.init(x: 10, y: 10, width: 100, height: 60)
        
        formsView.addSubview(self.incomeSelectView)
        self.incomeSelectView.frame = CGRect.init(x: self.spendingSelectView.frame.maxX + 20, y: 10, width: 100, height: 60)
        
        weak var weakSelf = self
        self.spendingSelectView.selectedCallback(callback: { (flag) in
            weakSelf?.incomeSelectView.isSelected = false
            weakSelf?.spendingSelectView.isSelected = true
            
            if weakSelf?.summaryType == SummaryType.month{
                weakSelf?.type = TallyType.monthlySpending
            }else{
                weakSelf?.type = TallyType.yearlySpending
            }
            weakSelf?.loadData()
            
        })
        
        self.incomeSelectView.selectedCallback(callback: { (flag) in
            weakSelf?.incomeSelectView.isSelected = true
            weakSelf?.spendingSelectView.isSelected = false
            
            if weakSelf?.summaryType == SummaryType.month{
                weakSelf?.type = TallyType.monthlyIncome
            }else{
                weakSelf?.type = TallyType.yearlyIncome
            }
            weakSelf?.loadData()
        })

        
        return aTableView
    }()
    
    //MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI();
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - SetupUI
    
    private func setupUI() -> Void {
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        
        let oneView = UIView.init()
        oneView.backgroundColor = themeColor
        self.view.addSubview(oneView)
        oneView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(120 + kNavigationHeight)
        }
        
        let titleLabel = UILabel.init()
        titleLabel.text = "报表"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.init(name: "PingFang SC-Regular", size: 17)
        titleLabel.textColor = UIColor.white
        oneView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(kStatusBarHeight)
            make.height.equalTo(44)
        }
        
        oneView.addSubview(self.dateSelectView)
        self.dateSelectView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.right.left.equalTo(0)
            make.height.equalTo(50)
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(oneView.snp.bottom).offset(-50)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        
        self.dateSelectView.selectedDateCallback { (year, month) in
            self.loadData()
        }
        
    }
    
    //MARK: - LoadData
    
    func loadData() -> Void {
        
        let date: String = self.date
        let type: TallyType = self.type
        
        if date.count < 4 {
            return
        }
        
        let sqlManager: SqlManager = SqlManager.shareInstance
        var spendingSummary: Summary?
        var incomeSummary: Summary?
        
        switch type {
            case .monthlySpending:
                spendingSummary =  sqlManager.query(userid: "00000000", tallyType: 1, summaryType: 1, date: date) ?? Summary.init()
                incomeSummary =  sqlManager.query(userid: "00000000", tallyType: 2, summaryType: 1, date: date) ?? Summary.init()
                break
            case .monthlyIncome:
                spendingSummary =  sqlManager.query(userid: "00000000", tallyType: 1, summaryType: 1, date: date) ?? Summary.init()
                incomeSummary =  sqlManager.query(userid: "00000000", tallyType: 2, summaryType: 1, date: date) ?? Summary.init()
                break
            case .yearlySpending:
                spendingSummary =  sqlManager.query(userid: "00000000", tallyType: 1, summaryType: 2, date: date) ?? Summary.init()
                incomeSummary =  sqlManager.query(userid: "00000000", tallyType: 2, summaryType: 2, date: date) ?? Summary.init()
                break
            case .yearlyIncome:
                incomeSummary =  sqlManager.query(userid: "00000000", tallyType: 2, summaryType: 2, date: date) ?? Summary.init()
                incomeSummary =  sqlManager.query(userid: "00000000", tallyType: 2, summaryType: 2, date: date) ?? Summary.init()
                break
        }
        
        self.spendingSelectView.amountLabel.text = String(format: "￥%@", spendingSummary?.totalamount ?? "0.00")
        self.incomeSelectView.amountLabel.text = String(format: "￥%@", incomeSummary?.totalamount ?? "0.00")

        let summary: Summary?
        if type == .monthlyIncome || type == .yearlyIncome {
            summary = incomeSummary
        }else{
            summary = spendingSummary
        }
        
        let array: Array<ConsumeType> = sqlManager.consumetype_query(pid: summary?.id ?? 0)
        let sortArray: Array<ConsumeType> = array.sorted { (now: ConsumeType, last: ConsumeType) -> Bool in
            if Double.init(now.keyValue ?? "") ?? 0.00 > Double.init(last.keyValue ?? "") ?? 0.00{
                return true
            }
            return false
        }
        
        self.list.removeAll()
        var reportFormsViewParams: Array<Any> = Array.init()
        var angle: Double = self.reportFormsView?.startAngle ?? -180.00
        var otherScale: Double = 0.00
        for consumeType: ConsumeType in sortArray{
            
            if Double.init(consumeType.keyValue ?? "") == 0.00{
                continue
            }
            
            let startAngle: Double = angle
            
            let scale: Double = (Double.init(consumeType.keyValue ?? "") ?? 0.00)/(Double.init(summary?.totalamount ?? "1") ?? 1.00)
            
            let reportFormsModel: ReportFormsModel = ReportFormsModel.init()
            reportFormsModel.consumeType = consumeType
            reportFormsModel.scale = scale
            if self.type == TallyType.yearlySpending || self.type == TallyType.monthlySpending{
                reportFormsModel.type = 1
            }else{
                reportFormsModel.type = 2
            }
            self.list.append(reportFormsModel)
            
            /*
            if scale < 0.035{
                otherScale += scale
                continue
            }
            */
            
            let endAngle: Double = angle - scale * 360
            
            let value1: UInt32 = arc4random() % 255
            let value2: UInt32 = arc4random() % 150
            let value3: UInt32 = arc4random() % 150
            let color: UIColor = UIColor.init(red: CGFloat(value1) / 255.0, green: CGFloat(value2) / 255.0, blue: CGFloat(value3) / 255.0, alpha: 1.0)
            
            let text: String = String(format: "%@ %d%%", consumeType.keyName ?? "", lroundf(Float(Double.init(scale * 100))))
            
            /*
            let dic: Dictionary = ["startAngle": startAngle, "endAngle": endAngle, "color": color, "text" : text] as [String : Any]
            reportFormsViewParams.append(dic)
            */
            
            let params: ReportFormsViewParameters = ReportFormsViewParameters.init()
            params.startAngle = startAngle
            params.endAngle = endAngle
            params.color = color
            params.text = text
            params.scale = scale
            reportFormsViewParams.append(params)
            
            angle = endAngle
            
        }
        
        /*
        if otherScale > 0 {
            
            let startAngle: Double = angle
            let endAngle: Double = angle - otherScale * 360

            let value1: UInt32 = arc4random() % 255
            let value2: UInt32 = arc4random() % 150
            let value3: UInt32 = arc4random() % 150
            let color: UIColor = UIColor.init(red: CGFloat(value1) / 255.0, green: CGFloat(value2) / 255.0, blue: CGFloat(value3) / 255.0, alpha: 1.0)
            
            let text: String = String(format: "其它 %d%%", lroundf(Float(Double.init(otherScale * 100))))

            let dic: Dictionary = ["startAngle": startAngle, "endAngle": endAngle, "color": color, "text" : text] as [String : Any]
            reportFormsViewParams.append(dic)

        }
        */
        
        self.reportFormsView?.params = reportFormsViewParams
        self.tableView.reloadData()
        
        
    }
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ReportFormsTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ReportFormsTableViewCell
        cell.reportFormsModel = list[indexPath.row]
        return cell
        
    }
}