import UIKit

enum SortParameter: Int {
    case instrumentName = 0
    case price = 1
    case amount = 2
    case side = 3
    case date
}

final class ViewController: UIViewController, HeaderDelegate {
    
    private let queue = DispatchQueue(label: "queue")
    private let changeSortQueue = DispatchQueue(label: "changeSortQueue")
    
    private let server = Server()
    private var serverModel: [Deal] = []
    
    private var model: [Deal] = []
    private var dataSource: [Deal] = []
    
    private var reversed = false
    private var sortParameter: SortParameter = .date {
        didSet {
            self.startAnimating()
            self.changeSortQueue.async {
                self.model = self.sort(self.serverModel, parameter: self.sortParameter, reversed: self.reversed)
                let count = self.dataSource.count == 0 ? 99 : self.dataSource.count - 1
                if count < self.model.count {
                    self.dataSource = Array(self.model[0...count])
                } else {
                    self.dataSource = []
                }
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                    self.stopAnimating()
                    self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    @IBOutlet private weak var loader: UIActivityIndicatorView?
    @IBOutlet private weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Deals"
        setup()
        
        server.subscribeToDeals { deals in
            self.serverModel.append(contentsOf: deals)
            
            self.queue.async {
                self.model = self.sort(self.serverModel, parameter: self.sortParameter, reversed: self.reversed)
                let count = self.dataSource.count == 0 ? 99 : self.dataSource.count - 1
                if count < self.model.count {
                    self.dataSource = Array(self.model[0...count])
                } else {
                    self.dataSource = []
                }
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
            
        }
    }
    
    func changeSort(parameter: SortParameter, reversed: Bool) {
        self.sortParameter = parameter
        self.reversed = reversed
    }
    
    private func setup() {
        tableView?.register(UINib(nibName: DealCell.reuseIidentifier, bundle: nil), forCellReuseIdentifier: DealCell.reuseIidentifier)
        tableView?.register(UINib(nibName: HeaderCell.reuseIidentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIidentifier)
        tableView?.delegate = self
        tableView?.dataSource =  self
    }
    
    private func startAnimating() {
        self.loader?.startAnimating()
        self.tableView?.isHidden = true
    }
    
    private func stopAnimating() {
        self.loader?.stopAnimating()
        self.tableView?.isHidden = false
    }
    
    private func sort(_ array: [Deal], parameter: SortParameter, reversed: Bool) -> [Deal] {
        if reversed {
            switch parameter {
            case .price:
                return array.sorted(by: { $0.price > $1.price })
            case .instrumentName:
                return array.sorted(by: { $0.instrumentName > $1.instrumentName })
            case .amount:
                return array.sorted(by: { $0.amount > $1.amount })
            case .side:
                return array.sorted(by: { $0.side > $1.side })
            case .date:
                return array.sorted(by: { $0.dateModifier.compare($1.dateModifier) == .orderedDescending })
            }
        } else {
            switch parameter {
            case .price:
                return array.sorted(by: {$0.price < $1.price })
            case .instrumentName:
                return array.sorted(by: { $0.instrumentName < $1.instrumentName })
            case .amount:
                return array.sorted(by: { $0.amount < $1.amount })
            case .side:
                return array.sorted(by: { $0.side < $1.side })
            case .date:
                return array.sorted(by: { $0.dateModifier.compare($1.dateModifier) == .orderedAscending })
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.reuseIidentifier, for: indexPath) as! DealCell
        cell.set(model: dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderCell.reuseIidentifier) as! HeaderCell
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > (scrollView.contentSize.height / 1.5)
        {
            let count = dataSource.count / 100 + 1
            let leftSide = count * 100
            let rightSide = (count * 100) + 99
            
            guard rightSide < model.count else {
                return
            }
            
            dataSource.append(contentsOf: model[leftSide...rightSide])
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
}

