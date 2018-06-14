//
//  BalanceLabel.swift
//  Kinit
//

import UIKit

class BalanceLabel: KinAmountLabel {
    private let kin: Kin

    fileprivate var balance: UInt64 = 0 {
        didSet {
            DispatchQueue.main.async {
                self.amount = self.balance
            }
        }
    }

    init(kin: Kin) {
        self.kin = kin
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
    func balanceDidUpdate(balance: UInt64) {
        self.balance = balance
    }
}
