//
//  PerformantTableViewCell
//  ExampleApplication
//
//  Created by Kevin Conner on 9/1/18.
//  Copyright © 2018 Kevin Conner. All rights reserved.
//

import UIKit

// This cell is expensive to create since its layout is complex,
// but it's cheap to reuse since its layout does not depend on row data.

final class ExpensiveTableViewCell: UITableViewCell {

    @IBOutlet private var rootStackView: UIStackView!

}

extension ExpensiveTableViewCell: RowConfiguring {

    func configure(at index: Int) {
        let title = "Expensive\nRow"
        for case let stackView as UIStackView in rootStackView.arrangedSubviews {
            for case let label as UILabel in stackView.arrangedSubviews {
                label.text = title
            }
        }
    }

}
