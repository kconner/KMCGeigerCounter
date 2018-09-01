//
//  CheapTableViewCell.swift
//  ExampleApplication
//
//  Created by Kevin Conner on 9/1/18.
//  Copyright © 2018 Kevin Conner. All rights reserved.
//

import UIKit

// This cell is cheap to create since its layout is simple.
// It's also cheap to reuse since its layout does not depend on row data.

final class CheapTableViewCell: UITableViewCell {

    @IBOutlet private var titleLabel: UILabel!

}

extension CheapTableViewCell: RowConfiguring {

    func configure(at index: Int) {
        titleLabel.text = "Cheap\nRow \(index)"
    }

}
