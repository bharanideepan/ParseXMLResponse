//
//  FieldDataCell.swift
//  Sample URLSession
//
//  Created by Bharani on 31/03/20.
//  Copyright © 2020 bharani. All rights reserved.
//

import UIKit

class FieldDataCell: UITableViewCell {
    
    let textField : CustomTextField = {
        let textField = CustomTextField(frame: CGRect(x: 0, y: 0, width: 414, height: 60))
        return textField
    }()
    
    var field: Field? {
        didSet {
            self.textField.field = self.field
        }
    }
    var pickerWithToolBar: (picker: UIPickerView, toolBar: UIToolbar)? {
        didSet {
            self.textField.pickerWithToolBar = self.pickerWithToolBar
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(self.textField)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
