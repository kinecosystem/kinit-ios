//
//  BalanceLabel.swift
//  Kinit
//

import UIKit

class BalanceLabel: KinAmountLabel {
    enum BalanceType: Int {
        case local
        case aggregate
    }

    private let kin: Kin

    var balanceType: BalanceType = .local {
        didSet {
            switch balanceType {
            case .local:
                balance = kin.localBalance
            case .aggregate:
                balance = kin.aggregateBalance
            }
        }
    }

    fileprivate var balance: UInt64 = 0 {
        didSet {
            DispatchQueue.main.async {
                self.amount = self.balance
            }
        }
    }

    init(kin: Kin, balanceType: BalanceType = .local) {
        self.kin = kin
        self.balanceType = balanceType
        balance = kin.balance

        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        kin = Kin.shared
        balance = kin.balance

        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        font = FontFamily.Roboto.regular.font(size: 14)
        kin.addBalanceDelegate(self)
        textColor = .white
        amount = balance
    }
}

extension BalanceLabel: BalanceDelegate {
    func localBalanceDidUpdate(balance: UInt64) {
        guard balanceType == .local else {
            return
        }

        self.balance = balance
    }

    func aggregateBalanceDidUpdate(balance: UInt64) {
        guard balanceType == .aggregate else {
            return
        }

        self.balance = balance
    }
}
