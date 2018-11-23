//
//  GoalCell.swift
//  goalpost-app
//
//  Created by Gustavo Ferrufino on 2018-11-08.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit

class GoalCell: UITableViewCell {

   
    @IBOutlet weak var goalDescriptionLbl: UILabel!
    @IBOutlet weak var goalTypeLbl: UILabel!
    @IBOutlet weak var goalProgressLbl: UILabel!
    @IBOutlet weak var goalCompleted: UIView!
    
    func configCell(goal: Goal){
        
        self.goalDescriptionLbl.text = goal.goalDescription
        self.goalTypeLbl.text = goal.goalType
        self.goalProgressLbl.text = String(goal.goalProgressValue)
        
        if goal.goalProgressValue ==  goal.goalValue {
            self.goalCompleted.isHidden = false
        }else{
            self.goalCompleted.isHidden = true

        }
    }
    
}
