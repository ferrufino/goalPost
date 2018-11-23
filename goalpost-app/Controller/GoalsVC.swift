//
//  ViewController.swift
//  goalpost-app
//
//  Created by Gustavo Ferrufino on 2018-11-08.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class GoalsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var undoBtn: UIView!
    
    var undogoalDescription: String!
    var undogoalType: String!
    var undogoalProgressValue : Int32!
    var undogoalValue : Int32!
    
    var goals: [Goal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreDataObjects()
         tableView.reloadData()
    }
    func fetchCoreDataObjects(){
        self.fetch { (complete) in
            if complete {
                if goals.count >= 1 {
                    tableView.isHidden = false
                } else {
                    tableView.isHidden = true
                }
            }
        }
    }
    @IBAction func addGoalBtnPressed(_ sender: Any) {
        
        guard let createGoalVC = storyboard?.instantiateViewController(withIdentifier: "CreateGoalVC") else {return}
        
        presentDetail(createGoalVC)
    }
    
    @IBAction func undoBtnWasPressed(_ sender: Any) {
        self.addBackGoal()
        self.undoBtn.isHidden = true
        fetchCoreDataObjects()// get all the data
        tableView.reloadData() // update table view
        print("undo Btn was pressed finalized")
    }
}

extension GoalsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else {return UITableViewCell()}
        
        let goal = goals[indexPath.row]
        
        cell.configCell(goal: goal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { // allow editing in row
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none // by putting no editiing style allows us to create our own
    }

    //With this func we defined a way to edit the cells in a tableview
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            
           
            self.undogoalDescription = self.goals[indexPath.row].goalDescription
            self.undogoalProgressValue = self.goals[indexPath.row].goalProgressValue
            self.undogoalValue = self.goals[indexPath.row].goalValue
            self.undogoalType = self.goals[indexPath.row].goalType
            
           
            self.undoBtn.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.undoBtn.isHidden = true
            }
            
            self.removeGoal(atIndexPath: indexPath)
            self.fetchCoreDataObjects()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
        let addAction = UITableViewRowAction(style: .normal, title: "ADD ONE") { (rowAction, indexPath) in
            self.setProgress(atIndexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        addAction.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.8478213028)
        
        return [deleteAction, addAction]
    }
}

extension GoalsVC {
    func removeGoal(atIndexPath indexPath: IndexPath){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(goals[indexPath.row])
        
      
            do{
                try managedContext.save()
                print("Successfully deleted goal")
            } catch {
                debugPrint("Could not save deleted entry: \(error.localizedDescription)")
            }
       
       
    }
    func fetch(completion: (_ complete:Bool) -> ()){
        guard let manageContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        
        do{
            goals = try manageContext.fetch(fetchRequest)
            completion(true)
        } catch{
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func setProgress(atIndexPath indexPath:IndexPath){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let chosenGoal = goals[indexPath.row]
        
        if chosenGoal.goalProgressValue < chosenGoal.goalValue {
            chosenGoal.goalProgressValue += 1
        }else{
            return
        }
        
        //save to manage context
        
        do{
            try managedContext.save()
            print("successfully saved increased progress")
        }catch{
            debugPrint("Could not save progress \(error.localizedDescription)")
        }
    }
    
    func addBackGoal() {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let goal = Goal(context: managedContext)
        
        goal.goalDescription = self.undogoalDescription
        goal.goalProgressValue = self.undogoalProgressValue
        goal.goalValue = self.undogoalValue
        goal.goalType = self.undogoalType
        
        
       
        
        
    
        do{
            try managedContext.save()//persistant storage
            print("Successfully undo delete data")
        } catch {
            debugPrint("Could not save back undo: \(error.localizedDescription)")
        }
        
    }
}
