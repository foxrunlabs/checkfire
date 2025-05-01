import Foundation

struct TSPData: Codable, Equatable {
    private var _traditionalBasePay: Double = 0.00
    private var _traditionalSpecialPay: Double = 0.00
    private var _traditionalIncentivePay: Double = 0.00
    private var _traditionalBonusPay: Double = 0.00
    
    private var _rothBasePay: Double = 0.00
    private var _rothSpecialPay: Double = 0.00
    private var _rothIncentivePay: Double = 0.00
    private var _rothBonusPay: Double = 0.00
    
    // the traditional percentages and the Roth percentages must not be more than 100%, combined.
    var traditionalBasePay: Double {
        get { _traditionalBasePay }
        set { _traditionalBasePay = min(newValue, 1 - _rothBasePay) }
    }
    
    var traditionalSpecialPay: Double {
        get { _traditionalSpecialPay }
        set { _traditionalSpecialPay = min(newValue, 1 - _rothSpecialPay) }
    }
    
    var traditionalIncentivePay: Double {
        get { _traditionalIncentivePay }
        set { _traditionalIncentivePay = min(newValue, 1 - _rothIncentivePay) }
    }
    
    var traditionalBonusPay: Double {
        get { _traditionalBonusPay }
        set { _traditionalBonusPay = min(newValue, 1 - _rothBonusPay) }
    }
    
    var rothBasePay: Double {
        get { _rothBasePay }
        set { _rothBasePay = min(newValue, 1 - _traditionalBasePay) }
    }
    
    var rothSpecialPay: Double {
        get { _rothSpecialPay }
        set { _rothSpecialPay = min(newValue, 1 - _traditionalSpecialPay) }
    }
    
    var rothIncentivePay: Double {
        get { _rothIncentivePay }
        set { _rothIncentivePay = min(newValue, 1 - _traditionalIncentivePay) }
    }
    
    var rothBonusPay: Double {
        get { _rothBonusPay }
        set { _rothBonusPay = min(newValue, 1 - _traditionalBonusPay) }
    }
    
    init(
        traditionalBasePay: Double = 0.00,
        traditionalSpecialPay: Double = 0.00,
        traditionalIncentivePay: Double = 0.00,
        traditionalBonusPay: Double = 0.00,
        rothBasePay: Double = 0.00,
        rothSpecialPay: Double = 0.00,
        rothIncentivePay: Double = 0.00,
        rothBonusPay: Double = 0.00
    ) {
        self._traditionalBasePay = traditionalBasePay
        self._traditionalSpecialPay = traditionalSpecialPay
        self._traditionalIncentivePay = traditionalIncentivePay
        self._traditionalBonusPay = traditionalBonusPay
        
        self._rothBasePay = rothBasePay
        self._rothSpecialPay = rothSpecialPay
        self._rothIncentivePay = rothIncentivePay
        self._rothBonusPay = rothBonusPay
    }
    
    static let example = TSPData(traditionalBasePay: 0.11)
}
