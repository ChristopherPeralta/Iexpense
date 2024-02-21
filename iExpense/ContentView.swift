//
//  ContentView.swift
//  iExpense
//
//  Created by Christopher Peralta on 3/12/23.
//

import Observation
import SwiftUI
import Charts

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    
    
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    @State private var type: String?
    @State private var isFiltering = false
    @State private var valueChart: String?
    
    
    
    
    var filteredItems: [ExpenseItem] {
        guard let selectedType = type else {
            return expenses.items
        }
        return expenses.items.filter { $0.type == selectedType }
    }
    
    var uniqueItems: [ExpenseItem] {
            switch valueChart {
            case "type":
                return Dictionary(grouping: filteredItems, by: { $0.type })
                    .values
                    .compactMap { $0.first }
            case "name":
                return Dictionary(grouping: filteredItems, by: { $0.name })
                    .values
                    .compactMap { $0.first }
            default:
                return Dictionary(grouping: filteredItems, by: { $0.type })
                    .values
                    .compactMap { $0.first }
            }
        }
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 20) {
                Button("Personal") {
                    isFiltering = true
                    type = "Personal"
                    valueChart = "name"
                }
                .buttonStyle(MyButtonStyle())
                
                Button("Business") {
                    isFiltering = true
                    type = "Business"
                    valueChart = "name"
                    
                }
                .buttonStyle(MyButtonStyle())
                
                Button("Both") {
                    isFiltering = false
                    type = nil
                    valueChart = "type"
                }
                .buttonStyle(MyButtonStyle())
            }
            
            //PIE CHART
            VStack(alignment: .leading){
                
            
                ZStack {
                    Chart(uniqueItems, id: \.id) { item in
                        SectorMark(
                            angle: .value("Expense", item.amount),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(4)
                        .foregroundStyle(by: .value("Expenses", getLabel(for: item)))
                    }
                    .frame(width: 300 , height: 300)

                    VStack {
                        Text(chartTitle)
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("Expenses")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                }
                
            }
            
            //LIST EXPENSES
            List {
                ForEach(filteredItems, id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            
                            Text(item.type)
                        }
                        
                        Spacer()
                        Text(item.amount, format: .currency(code: "PEN"))
                            .foregroundColor(
                                item.amount > 1000 ? .green :
                                    item.amount > 0 ? .blue :
                                        .red
                            )
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("Expense Tracker")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
        
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
    
    func getLabel(for item: ExpenseItem) -> String {
        switch valueChart {
        case "name":
            return item.name
        case "type":
            return item.type
        default:
            return item.type
        }
    }
    
    //Para colocar el titulo del grafico circular
    var chartTitle: String {
        switch type {
        case "Personal":
            return "Personal"
        case "Business":
            return "Business"
        case nil:
            return "Both"
        default:
            return ""
        }
    }
}
    

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
    }
}

#Preview {
    ContentView()
}

