//
//  ExpensiveTableViewCell.swift
//  ExampleApplication
//
//  Created by Kevin Conner on 9/1/18.
//  Copyright © 2018 Kevin Conner. All rights reserved.
//

import UIKit

// This cell is expensive to create since its layout is complex.
// It's also expensive to reuse since its layout depends on row data.

final class ExorbitantTableViewCell: UITableViewCell {

    @IBOutlet private var rootStackView: UIStackView!

}

extension ExorbitantTableViewCell: RowConfiguring {

    func configure(at index: Int) {
        let title = "Exorbitant\nRow \(index)"
        let spacing = CGFloat(index)

        rootStackView.spacing = spacing

        for case let stackView as UIStackView in rootStackView.arrangedSubviews {
            stackView.spacing = spacing

            for case let label as UILabel in stackView.arrangedSubviews {
                label.text = title
            }
        }
    }

}
