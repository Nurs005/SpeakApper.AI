//
//  File.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 20.06.2025.
//

import Foundation


enum ProductType: String, CaseIterable{
    case annual = "01"
    case monthly = "02"
    case weekly = "03"
    
    init?(id: String) {
        switch id {
        case "01":
            self = .annual
            break
        case "001":
            self = .annual
            break
        case "02":
            self = .monthly
            break
        case "03":
            self = .weekly
            break
        default: return nil
        }
    }
    
    var title: String {
        switch self {
        case .annual:
            return "Годовой план"
        case .monthly:
            return "Mecячный план"
        case .weekly:
            return "Недельный план"
        }
    }
    
    var subtitle: String {
        switch self {
        case .annual:
            return "всего %@ в месяц"
        case .monthly:
            return "всего %@ в день"
        case .weekly:
            return "всего %@ в день"
        }
    }
    
    var price: String {
        switch self {
        case .annual:
            return "%@ в год"
        case .monthly:
            return "%@ в месяц"
        case .weekly:
            return "%@ в неделю"
        }
    }
    
    var isBestValue: Bool {
        // TODO: need to be cahnged when we add a promos
        return false
    }
    
    var periodsPerYear: Decimal {
        switch self {
        case .annual:
            return 12
        case .monthly:
            return 30
        case .weekly:
            return 7
        }
    }
}

extension ProductType {
    func formattedSubtitle(totalPrice: Decimal, currencyCode: String) -> String {
        let perPeriodPrice = (totalPrice / periodsPerYear)

          
          let formatter = NumberFormatter()
          formatter.numberStyle = .currency
          formatter.currencyCode = currencyCode
          formatter.minimumFractionDigits = 2
          formatter.maximumFractionDigits = 2

          let priceString = formatter.string(from: perPeriodPrice as NSDecimalNumber) ?? "\(perPeriodPrice)"

        return String(format: subtitle, priceString)
    }

    func formattedTotalPrice(totalPrice: Decimal, currencyCode: String) -> String {
          let formatter = NumberFormatter()
          formatter.numberStyle = .currency
          formatter.currencyCode = currencyCode
          formatter.minimumFractionDigits = 2
          formatter.maximumFractionDigits = 2

          return formatter.string(from: totalPrice as NSDecimalNumber) ?? "\(totalPrice)"
      }
}
