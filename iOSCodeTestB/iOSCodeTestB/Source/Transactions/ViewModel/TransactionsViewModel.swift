//  TransactionsViewModel.swift
//  iOSCodeTestB
//
//  Created by Simón Aparicio on 11/03/2020.
//  Copyright © 2020 iPon.es. All rights reserved.
//

import Foundation
import Alamofire

protocol TransactionsViewModel {
    
    var transactions: Observable<Transactions> {get}
    var firstTransaction: Observable<Transaction> {get}
    var counters: Observable<Counters> {get}
    

    func retrieveTransactions()
    func searchText(_ text: String)
    func getCurrentEndPoint() -> ApiConfig.EndPoint
    func setCurrentEndPoint(_ endPoint: ApiConfig.EndPoint)
}

// Here the business logic
class TransactionsViewModelImpl: TransactionsViewModel {
    
    var transactions = Observable<Transactions>([], thread: .main)
    var firstTransaction = Observable<Transaction>(nil, thread: .main)
    var counters = Observable<Counters>(Counters(), thread: .main)
    var localTransactions: [Transaction] = []

    private var filterText: String = "" {
        didSet {
            updateTransactionsWithFilter()
        }
    }
    
    private var endPoint: ApiConfig.EndPoint = .serverA {
        didSet {
            retrieveTransactions()
        }
    }

    // The webservice call
    func retrieveTransactions() {
        
        debugPrint("retrieveTransactions - Retrieving transactions from Webservice..")
        
        let url = ApiConfig.baseURL + endPoint.rawValue

        AF.request(url).responseJSON {[weak self] response in
            
            guard let serverData = response.data, let transactions = try? JSONDecoder().decode(Transactions.self, from: serverData) else {
                debugPrint("retrieveTransactions - Can't decoding server response")
                return
            }
            
            //guard let `self` = self else{ return }
            
            self?.transactions.value = transactions
            self?.counters.value?.total = transactions.count

            // 1 - Clean items with wrong formatted dates
            self?.transactions.value = self?.transactions.value?.onlyDatedTransactions
            self?.counters.value?.valid = self?.transactions.value?.count ?? 0

            // 2 - Sort descending by date and finally
            self?.transactions.value = self?.transactions.value?.sorted(by: { $0.date! > $1.date! })

            // 3 - Remove duplicates by id (fixed in 1.0.2)
            self?.transactions.value = self?.transactions.value?.uniqueElements
            self?.counters.value?.unique = self?.transactions.value?.count ?? 0

            // 4 - Move first element
            self?.firstTransaction.value = self?.transactions.value?.first
            self?.transactions.value = Array((self?.transactions.value?.dropFirst() ?? []))
            self?.localTransactions = self?.transactions.value ?? []
            
            // 5 - Update filter, needed if endPoint changes
            self?.updateTransactionsWithFilter()
        }
        
    }
        
    func updateTransactionsWithFilter () {
        
        if !filterText.isEmpty {
            transactions.value = localTransactions.filter({
                ($0.description ?? "").lowercased().contains(filterText.lowercased())
            })
            counters.value?.filtered = transactions.value?.count ?? 0

        } else {
            transactions.value = localTransactions
        }
    }
    
    func searchText(_ text: String) {
        filterText = text
    }
    
    func setCurrentEndPoint(_ endPoint: ApiConfig.EndPoint) {
        self.endPoint = endPoint
    }
    
    func getCurrentEndPoint() -> ApiConfig.EndPoint {
        return endPoint
    }

}
