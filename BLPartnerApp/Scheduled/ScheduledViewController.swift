//
//  ScheduledViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 16/08/24.
//

import UIKit
protocol ScheduledViewControllerProtocol: AnyObject {
    func didDismissView()
    
    func didDismissWithObject(isCurrentTrip: Bool, trip: AllTripsData)
}

class ScheduledViewController: BaseViewController {
    @IBOutlet weak var segmentedDay: UISegmentedControl!
    @IBOutlet weak var scheduledTableView: UITableView!
    @IBOutlet weak var containerScheduledView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    weak var delegate: ScheduledViewControllerProtocol?
    var jobsData: [JobsData] = []
    var todayData: [AllTripsData] = []
    var tomorrowsData: [AllTripsData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.getTrips()
        segmentedDay.setTitle("Today", forSegmentAt: 0)
        segmentedDay.setTitle("Tomorrow", forSegmentAt: 1)
        segmentedDay.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        containerScheduledView.layer.cornerRadius = 16
        containerScheduledView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.containerView.isUserInteractionEnabled = true
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissContent)))
    }
    
    @objc override func dismissContent() {
        self.dismiss(animated: false)
        delegate?.didDismissView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
        self.getTrips()
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [.curveEaseOut], animations: {
            self.containerScheduledView.alpha = 1
        })
    }
    
    func getTrips(){
        self.postAll() { result in
            switch result {
            case .success(let responseModel):
                DispatchQueue.main.async {
                    if responseModel.data?.indices.contains(0) == true {
                        self.todayData = responseModel.data?[0] ?? []
                    }
                    if responseModel.data?.indices.contains(1) == true {
                        self.tomorrowsData = responseModel.data?[1] ?? []
                    }
                    self.scheduledTableView.reloadData()
                }
                
            case .failure(let error):
                print("failed post all job")
            }
        }
    }
    
    func setupTableView() {
        self.scheduledTableView.dataSource = self
        self.scheduledTableView.delegate = self
        self.scheduledTableView.register(UINib(nibName: "ScheduledViewCell", bundle: nil), forCellReuseIdentifier: "ScheduledViewCell")
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        scheduledTableView.reloadData()
    }
}

extension ScheduledViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedDay.selectedSegmentIndex {
        case 0:
            return todayData.count
        case 1:
            return tomorrowsData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduledViewCell") as? ScheduledViewCell else {
            return UITableViewCell()
        }
        BasicAlert.shared.showLoading(self.view)
        switch segmentedDay.selectedSegmentIndex {
        case 0:
            BasicAlert.shared.dismiss()
            cell.allTrips = self.todayData
            cell.setupData(
                jobsData: todayData[indexPath.row].points?.first,
                endPoinnt: todayData[indexPath.row].points?.last,
                codeName: todayData[indexPath.row].codeName ?? "",
                serviceType: todayData[indexPath.row].adhoc?.serviceType ?? "",
                vehicleNo: todayData[indexPath.row].vehicleNo ?? "", 
                duration: todayData[indexPath.row].adhoc?.duration ?? ""
            )
        case 1:
            BasicAlert.shared.dismiss()
            cell.allTrips = self.tomorrowsData
            cell.setupData(
                jobsData: tomorrowsData[indexPath.row].points?.first,
                endPoinnt: tomorrowsData[indexPath.row].points?.last,
                codeName: tomorrowsData[indexPath.row].codeName ?? "",
                serviceType: tomorrowsData[indexPath.row].adhoc?.serviceType ?? "",
                vehicleNo: tomorrowsData[indexPath.row].vehicleNo ?? "",
                duration: tomorrowsData[indexPath.row].adhoc?.duration ?? ""
            )
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedDay.selectedSegmentIndex {
        case 0:
            self.dismiss(animated: false)
            delegate?.didDismissWithObject(isCurrentTrip: false, trip: self.todayData[indexPath.row])
        case 1:
            self.dismiss(animated: false)
            delegate?.didDismissWithObject(isCurrentTrip: false, trip: self.tomorrowsData[indexPath.row])
        default:
            break
        }
    }
}
