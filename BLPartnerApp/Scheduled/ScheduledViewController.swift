//
//  ScheduledViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 16/08/24.
//

import UIKit

class ScheduledViewController: UIViewController {
    @IBOutlet weak var segmentedDay: UISegmentedControl!
    @IBOutlet weak var scheduledTableView: UITableView!
    var jobsData: [JobsData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        segmentedDay.setTitle("Today", forSegmentAt: 0)
        segmentedDay.setTitle("Tomorrow", forSegmentAt: 1)
    }
    
    func setupTableView() {
        self.scheduledTableView.dataSource = self
        self.scheduledTableView.delegate = self
        self.scheduledTableView.register(UINib(nibName: "ScheduledViewCell", bundle: nil), forCellReuseIdentifier: "ScheduledViewCell")
    }
    
}

extension ScheduledViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduledViewCell") as? ScheduledViewCell else {
            return UITableViewCell()
        }
        return cell
    }
}
