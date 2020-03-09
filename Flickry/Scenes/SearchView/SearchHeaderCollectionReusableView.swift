//
//  HeaderCollectionReusableView.swift
//  Flickry
//
//  Created by Mersad Ewaz Zadeh on 07.03.20.
//  Copyright © 2020 Mersad Ewaz Zadeh. All rights reserved.
//

import UIKit

class SearchHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var headerLable: UILabel!

    func setup(text: String) {
        headerLable.text = text
    }
}
