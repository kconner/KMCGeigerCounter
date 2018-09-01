//
//  TableViewController.swift
//  ExampleApplication
//
//  Created by Kevin Conner on 9/1/18.
//  Copyright © 2018 Kevin Conner. All rights reserved.
//

import UIKit

final class TableViewController: UITableViewController {

    @IBOutlet var cellTypeSegmentedControl: UISegmentedControl!

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = CellType(rawValue: cellTypeSegmentedControl.selectedSegmentIndex) ?? .expensive
        let cellIdentifier = cellType.cellIdentifier

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        if let rowConfiguringCell = cell as? RowConfiguring {
            rowConfiguringCell.configure(at: indexPath.row)
        }

        return cell
    }

}
