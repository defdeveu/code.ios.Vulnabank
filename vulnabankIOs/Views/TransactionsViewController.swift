//
//  TransactionsViewController.swift
//  vulnabankIOs
//

import Foundation
import UIKit

final class TransactionsViewController: UITableViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    fileprivate let viewModel:TransactionsViewModel = TransactionsViewModel()
    
    override func viewDidLoad() {
        
        viewModel.onRefreshUi.addObserver { [weak self] _ in
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsMultipleSelectionDuringEditing = true
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(self.reloadTableData), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        
        setButtons()
    }
    
    @objc func reloadTableData(_ sender: AnyObject) {
        viewModel.getAllTransaction()
    }
    
    @IBAction func editTouched(_ sender: Any) {
        if tableView.isEditing {
            deleteSelectedRows()
        }
        tableView.setEditing(!tableView.isEditing, animated: true)
        tableView.reloadData()
        setButtons()
    }
    
    @IBAction func cancelTouched(_ sender: Any) {
        tableView.isEditing = false
        setButtons()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.StoryBoarsIds.cellReuseIdentifier, for: indexPath) as? TransactionCellView else {
            return UITableViewCell()
        }
        
        cell.setTransaction(transaction: self.viewModel.transactions[indexPath.row], inEditingMode: tableView.isEditing)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteTransaction(transaction: viewModel.transactions[indexPath.row])
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (self.tableView.isEditing) {
            return UITableViewCell.EditingStyle.none;
        }
        
        return UITableViewCell.EditingStyle.delete;
    }
    
    fileprivate func setButtons() {
        editButton.title = tableView.isEditing ? "Delete" : "Edit"
        cancelButton.tintColor = tableView.isEditing ? .systemBlue : .clear
        cancelButton.isEnabled = tableView.isEditing
    }
    
    fileprivate func deleteSelectedRows() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            
            viewModel.deleteTransactions(byIndexes: selectedRows.map({$0.row}))
            
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .automatic)
            tableView.endUpdates()
        }
    }
}
