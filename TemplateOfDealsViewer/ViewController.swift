import UIKit

enum SortParameter: Int {
    case instrumentName = 0
    case price = 1
    case amount = 2
    case side = 3
}

final class ViewController: UIViewController {
    
    private let server = Server()
    private var model: [Deal] = []
    
    private var dataSource: [Deal] = []
    
    @IBOutlet private weak var loader: UIActivityIndicatorView?
    @IBOutlet private weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Deals"
        setup()
        
        startAnimating()
        
        server.subscribeToDeals { deals in
            self.model.append(contentsOf: deals)
        } completion: {
            self.model = self.initialSort(array: self.model)
            self.dataSource = Array(self.model[0...99])
            DispatchQueue.main.async {
                self.stopAnimating()
                self.tableView?.reloadData()
            }
        }
    }
    
    private func setup() {
        tableView?.register(UINib(nibName: DealCell.reuseIidentifier, bundle: nil), forCellReuseIdentifier: DealCell.reuseIidentifier)
        tableView?.register(UINib(nibName: HeaderCell.reuseIidentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIidentifier)
        tableView?.delegate = self
        tableView?.dataSource =  self
    }
    
    private func startAnimating() {
        DispatchQueue.main.async {
            self.loader?.startAnimating()
            self.tableView?.isHidden = true
        }
    }
    
    private func stopAnimating() {
        DispatchQueue.main.async {
            self.loader?.stopAnimating()
            self.tableView?.isHidden = false
        }
    }
    
    private func initialSort(array: [Deal]) -> [Deal] {
        return array.sorted(by: { $0.dateModifier.compare($1.dateModifier) == .orderedAscending } )
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, HeaderDelegate {
    
    func sort(parameter: SortParameter, reversed: Bool) {
        let queue = DispatchQueue(label: "sort")
        queue.async {
            self.startAnimating()
            if reversed {
                switch parameter {
                case .price:
                    self.model = self.model.sorted(by: { $0.price > $1.price })
                case .instrumentName:
                    self.model = self.model.sorted(by: { $0.instrumentName > $1.instrumentName })
                case .amount:
                    self.model = self.model.sorted(by: { $0.amount > $1.amount })
                case .side:
                    self.model = self.model.sorted(by: { $0.side > $1.side })
                }
            } else {
                switch parameter {
                case .price:
                    self.model = self.model.sorted(by: { $0.price < $1.price })
                case .instrumentName:
                    self.model = self.model.sorted(by: { $0.instrumentName < $1.instrumentName })
                case .amount:
                    self.model = self.model.sorted(by: { $0.amount < $1.amount })
                case .side:
                    self.model = self.model.sorted(by: { $0.side < $1.side })
                }
            }
            
            self.dataSource = Array(self.model[0...99])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView?.reloadData()
                self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self.stopAnimating()
            }
        }
    }
    
    
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

