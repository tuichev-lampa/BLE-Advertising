//
//  ViewController.swift
//  BLE test
//
//  Created by Lampa on 25.11.2020.
//

import UIKit

protocol ViewControllerProtocol: class {
    func addItem(item: String)
    func removeAdvertisingAfter()
}

class ViewController: UIViewController {

    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var switcher: UISwitch!
    
    @IBOutlet weak var tableView: UITableView!
    var adv: AdvertisingService?
    var switcherState: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "switcher")
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "switcher")
        }
    }
    
    var items: [String] = []
    {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.items.count == 0 { return }
                let indexPath = IndexPath(row: self.items.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        switcher.isOn = switcherState
        updateAdvertisingStatus()
        adv?.delegate = self
    }
    
    private func setupViews() {
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "TestTableViewCell", bundle: nil), forCellReuseIdentifier: "TestTableViewCell")
    }

    @IBAction func switchAction(_ sender: UISwitch) {
        updateAdvertisingStatus()
        switcherState = switcher.isOn
        
    }
    
    @IBAction func clearButtonTouchUpInside(_ sender: UIButton) {
        items = []
    }
    
    private func updateAdvertisingStatus() {
        if switcher.isOn {
            adv = nil
            AdvertisingService.canAdvertise = true
            adv = AdvertisingService()
            adv?.delegate = self
        } else {
            AdvertisingService.canAdvertise = false
            adv?.stopAdvertise()
        }
        
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestTableViewCell", for: indexPath) as! TestTableViewCell
        cell.titleLabel.text = items[indexPath.row]
        return cell
    }
}

// MARK: - ViewControllerProtocol
extension ViewController: ViewControllerProtocol {
    func addItem(item: String) {
        self.items.append(item)
    }
    
    func removeAdvertisingAfter() {
        addItem(item: "removeAdvertising after: 3 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.adv = nil
        })
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    // Cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return getSectionHeaderHeight(section: section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return getSectionHeaderHeight(section: section)
    }
    
    private func getSectionHeaderHeight(section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    // Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return getSectionFooterHeight(section: section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return getSectionFooterHeight(section: section)
    }
    
    private func getSectionFooterHeight(section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}
