//
//  LearningViewController.swift
//  datn-app
//
//  Created by ThiemJason on 11/18/22.
//

import UIKit
import RxCocoa
import RxSwift

class LearningViewController: UIViewController {
    @IBOutlet weak var tbvContent       : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalizedContent()
    }
    
    private func initalizedContent() {
        self.setupView()
        self.handlerAction()
        self.setupBinding()
    }
    
    private func setupView() {
        self.view.backgroundColor   = Constant.Color.app_background
        self.setupNavigation()
        self.setupTableView()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "icon_splash_background"), for: .top, barMetrics: .default)
        self.navigationController?.navigationBar.isTranslucent          = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupNavigation() {
        let label = UILabel()
        label.textColor     = UIColor.white
        label.text          = "Góc học tập";
        label.font          = UIFont.getOpenSansSemiBoldFontTitle()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        let notification                        = UIImage(named: "logo_circle_png")
        let notificationImgView                 = UIImageView(image: notification)
        notificationImgView.frame               = CGRect(x:0.0,y:0.0, width:35,height:35)
        notificationImgView.contentMode         = .scaleAspectFit
        let imgRightItem                        = UIBarButtonItem(customView: notificationImgView)
        let widthConstraintRight                = notificationImgView.widthAnchor.constraint(equalToConstant: 35)
        let heightConstraintRight               = notificationImgView.heightAnchor.constraint(equalToConstant: 35)
        heightConstraintRight.isActive          = true
        widthConstraintRight.isActive           = true
        self.navigationItem.rightBarButtonItem  =  imgRightItem
    }
    
    private func setupTableView() {
        self.tbvContent.alwaysBounceVertical    = false
        self.tbvContent.delegate        = self
        self.tbvContent.dataSource      = self
        self.tbvContent.separatorStyle  = .none
        self.tbvContent.alwaysBounceVertical    = false
        self.tbvContent.register(UINib(nibName: "PopularFeatureCell", bundle: nil), forCellReuseIdentifier: "PopularFeatureCell")
        self.tbvContent.register(UINib(nibName: "DefaultHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultHomeTableViewCell")
        self.tbvContent.register(UINib(nibName: "HeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
        self.tbvContent.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        self.tbvContent.register(UINib(nibName: "HotNewsCell", bundle: nil), forCellReuseIdentifier: "HotNewsCell")
        self.tbvContent.register(UINib(nibName: "UrgenNotiCell", bundle: nil), forCellReuseIdentifier: "UrgenNotiCell")
    }
    
    private func handlerAction() {
        
    }
    
    private func setupBinding() {
        
    }
}

extension LearningViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
