import UIKit

enum SortState {
    case normal
    case reversed
    case unknown
}

protocol HeaderDelegate: AnyObject {
    
    func sort(parameter: SortParameter, reversed: Bool)
}

final class HeaderCell: UITableViewHeaderFooterView {
    static let reuseIidentifier = "HeaderCell"
    
    @IBOutlet weak var instrumentNameTitlLabel: UILabel?
    @IBOutlet weak var priceTitleLabel: UILabel?
    @IBOutlet weak var amountTitleLabel: UILabel?
    @IBOutlet weak var sideTitleLabel: UILabel?
    
    @IBOutlet var sortButtons: [UIButton]!
    
    weak var delegate: HeaderDelegate?
    
    private var states: [SortState] = [.unknown, .unknown, .unknown, .unknown]
    
    @IBAction func sortButtonsPressed(_ sender: UIButton) {
        
        for button in sortButtons {
            button.setImage(UIImage(systemName: "questionmark.app"), for: .normal)
        }
        
        guard let parameter = SortParameter(rawValue: sender.tag) else {
            return
        }
        switch states[sender.tag] {
        case .unknown:
            states = [.unknown, .unknown, .unknown, .unknown]
            delegate?.sort(parameter: parameter, reversed: false)
            states[sender.tag] = .normal
            sortButtons[sender.tag].setImage(UIImage(systemName: "arrow.up"), for: .normal)
        case .reversed:
            delegate?.sort(parameter: parameter, reversed: false)
            states[sender.tag] = .normal
            sortButtons[sender.tag].setImage(UIImage(systemName: "arrow.up"), for: .normal)
        case .normal:
            delegate?.sort(parameter: parameter, reversed: true)
            states[sender.tag] = .reversed
            sortButtons[sender.tag].setImage(UIImage(systemName: "arrow.down"), for: .normal)
        }
    }
}
