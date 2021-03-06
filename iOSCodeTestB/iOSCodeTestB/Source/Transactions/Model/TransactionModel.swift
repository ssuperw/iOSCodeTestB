//  TransactionModel.swift
//  iOSCodeTestB
//
//  Created by Simón Aparicio on 11/03/2020.
//  Copyright © 2020 iPon.es. All rights reserved.
//

import Foundation

// MARK: - Transaction

/**
 "id":1442,
 "date":"2018-07-24T18:10:10.000Z", //wrong formatted will be descarted
 "amount":-113.86,
 "description":"" //also null
 */

typealias Transactions = [Transaction]

struct Transaction: Codable, Hashable { // needed hashable to remove duplicates
    
    let id: Int
    let date: Date?
    let amount: Double
    let fee: Double?
    let description: String?

    init(id: Int, date: Date?, amount: Double, fee: Double?, description: String?) {
        self.id = id
        self.date = date
        self.amount = amount
        self.fee = fee
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case id, date, amount, fee, description
    }

    // init from decoder trying to get:
    //       - id as Int
    //       - only dates well formated as Date
    //       - amount, fee as Double
    //       - description as String

    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        
        if let dateStr = try? container.decodeIfPresent(String.self, forKey: .date) {
            date = Date.dateFormatted(dateString: dateStr)
            
        } else {
            date = nil
        }
        
        amount = try container.decode(Double.self, forKey: .amount)
        fee = try? container.decodeIfPresent(Double.self, forKey: .fee)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
    }
    
    init() {
        self.id = 0
        self.date = nil
        self.amount = 0.0
        self.fee = nil
        self.description = "Espere, leyendo contenido …"
    }
    
    // needed to remove duplicates (by id)
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
}



/** JSON FROM URL: https://api.myjson.com/bins/1a30k8

[{"id":4734,"date":"2018-07-11T22:49:24.000Z","amount":-193.38,"fee":-3.18,"description":"Lorem ipsum dolor sit amet"},{"id":2210,"date":"2018-07-14T16:54:27.000Z","amount":165.36,"description":"Est ullamco mollit ad in in proident."},{"id":1442,"date":"2018-07-24T18:10:10.000Z","amount":-113.86,"description":""},{"id":8396,"date":"2018--11T11:31:27.000Z","amount":-153.62,"fee":-3.14,"description":"Quis reprehenderit ullamco incididunt non ut."},{"id":3369,"date":"2018-07-19T21:33:19.000Z","amount":-38.67},{"id":2911,"date":"2018-07-29T17:56:43.000Z","amount":87.84,"fee":-1.11,"description":"Veniam sit ut pariatur do."},{"id":2911,"date":"2018-07-21T19:13:23.000Z","amount":37.74,"fee":0.0,"description":"Lorem et incididunt aute cillum."},{"id":6595,"date":"2018-07-22T13:48:48.000Z","amount":87.95,"description":"Minim non sunt cupidatat magna nisi ut duis."},{"id":3371,"date":"2018-07-24T21:29:11.000Z","amount":-161.56,"fee":-4.95,"description":null},{"id":6068,"date":"2018-07-26T15:20:52.000Z","amount":92.54,"description":"Nostrud laboris id officia aliquip."},{"id":5038,"date":"2018-07-30T19:36:60.000Z","amount":184.98},{"id":6595,"date":"2018-07-24T56.000Z","amount":-37.22,"fee":-3.99,"description":"Veniam deserunt ut ullamco et ut."},{"id":2117,"date":"2018-07-28T14:14:17.000Z","amount":96.56,"description":""},{"id":2857,"date":"07-22T13:51:12.000Z","amount":-144.63,"fee":-4.74,"description":"Tempor dolor laboris minim cupidatat duis nisi ad."},{"id":9745,"date":"2018-07-26T19:26:10.000Z","amount":166.83,"description":"Fugiat elit cupidatat ipsum ad Lorem aliquip."}]

 */
