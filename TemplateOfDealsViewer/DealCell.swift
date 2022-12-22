import UIKit

final class DealCell: UITableViewCell {
    static let reuseIidentifier = "DealCell"
    
    @IBOutlet weak var instrumentNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var amountLabel: UILabel?
    @IBOutlet weak var sideLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(model: Deal) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        dateLabel?.text = df.string(from: model.dateModifier)
        instrumentNameLabel?.text = model.instrumentName
        priceLabel?.text = format(price: model.price)
        priceLabel?.textColor = model.side == .sell ? .red : .green
        amountLabel?.text = format(amount: model.amount)
        sideLabel?.text = "\(model.side)"
    }
    
    private func format(price: Double) -> String {
        return String(format: "%.2f", Float(price))
    }
    
    private func format(amount: Double) -> String {
        return String(format: "%.0f", Float(amount))
    }
}
