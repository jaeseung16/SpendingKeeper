//
//  SnapshotDetailView.swift
//  SpendingKeeper
//
//  Created by Jae Seung Lee on 8/10/24.
//

import SwiftUI
import Charts

struct SnapshotDetailView: View {
    @EnvironmentObject private var viewModel: SKViewModel
    
    @State var snapshot: SKSnapshot
    @State private var presentShareSheet = false
    
    private var sumOfIncome: Double
    private var sumOfSpending: Double
    
    private let miniumPercentageToDisplayAnootation = 10.0
    
    init(snapshot: SKSnapshot) {
        self.snapshot = snapshot
        
        self.sumOfIncome = snapshot.incomes?.map { $0.total }.reduce(0.0, +) ?? 0.0
        self.sumOfSpending = snapshot.spendings?.map { $0.total }.reduce(0.0, +) ?? 0.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                header
                
                Divider()
                
                if let spendings = snapshot.spendings {
                    Section {
                        HStack {
                            Chart(spendings, id: \.accoundId) {
                                barMark($0.accountName, $0.total, $0.total / sumOfSpending)
                            }
                            .chartYScale(domain: [0, 1.1 * sumOfSpending])
                            
                            Chart(spendings, id: \.accoundId) {
                                sectorMark($0.accountName, $0.total, $0.total / sumOfSpending)
                            }
                        }
                    } header: {
                        HStack {
                            Text("SPENDING")
                                .font(.title3)
                            Spacer()
                        }
                    }
                    .padding()
                }
                
                if let incomes = snapshot.incomes {
                    Section {
                        HStack {
                            Chart(incomes, id: \.accoundId) {
                                barMark($0.accountName, $0.total, $0.total / sumOfIncome)
                            }
                            .chartYScale(domain: [0, 1.1 * sumOfIncome])
                            
                            Chart(incomes, id: \.accoundId) {
                                sectorMark($0.accountName, $0.total, $0.total / sumOfIncome)
                            }
                        }
                    } header: {
                        HStack {
                            Text("INCOME")
                                .font(.title3)
                            Spacer()
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem {
                    ShareLink("Share", item: renderPdf())
                }
            }
        }
    }
    
    private var header: some View {
        Group {
            Text(snapshot.title)
                .font(.title)
            
            HStack {
                Spacer()
                
                Text("FROM")
                    .font(.caption)
                Text(snapshot.begin, format: Date.FormatStyle(date: .numeric, time: .omitted))

                Text("TO")
                    .font(.caption)
                Text(snapshot.end, format: Date.FormatStyle(date: .numeric, time: .omitted))
                
                Spacer()
                
                Text("CREATED ON").font(.caption)
                Text(snapshot.created, format: Date.FormatStyle(date: .numeric, time: .omitted))
                
                Spacer()
            }
        }
    }
    
    private func barMark(_ accountName: String, _ total: Double, _ fraction: Double) -> some ChartContent {
        BarMark(y: .value("Total", total))
        .foregroundStyle(by: .value("Account", accountName))
        .annotation(position: .overlay) {
            if fraction * 100.0 > miniumPercentageToDisplayAnootation {
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                    .font(.callout)
            }
        }
    }
    
    private func sectorMark(_ accountName: String, _ total: Double, _ fraction: Double) -> some ChartContent {
        SectorMark(angle: .value("Total", total))
            .foregroundStyle(by: .value("Account", accountName))
            .annotation(position: .overlay) {
                if fraction * 100.0 > miniumPercentageToDisplayAnootation {
                    Text(fraction, format: .percent.precision(.fractionLength(0)))
                        .font(.callout)
                }
            }
    }
    
    private func renderPdf() -> URL {
        let url = URL.documentsDirectory.appending(path: "\(snapshot.title).pdf")
        
        var box = CGRect(x: 0.0, y: 0.0, width: 612.0, height: 792.0)
        // https://pdfkit.org/docs/paper_sizes.html
        // A4 595.28 x 841.89
        // LETTER 612.00 X 792.00
        
        guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
            return url
        }
        
        pdf.beginPDFPage(nil)
        
        let renderer = ImageRenderer(content: pdfBody)
        renderer.render { size, renderer in
            // size=(467.0, 477.30908203125)
            
            // Will place the view in the middle of pdf on x-axis
            let xTranslation = box.size.width / 2.0 - size.width / 2.0
            let yTranslation = box.size.height / 2.0 - size.height / 2.0
            // Spacing between the views on y-axis
            let spacing: CGFloat = 20

            // TODO: - View starts printing from bottom, need to inverse Y position
            pdf.translateBy(x: xTranslation, y: yTranslation + spacing)

            // Render the SwiftUI view data onto the page
            renderer(pdf)
        }
        
        pdf.endPDFPage()
        
        pdf.closePDF()
        
        return url
    }
    
    private var pdfBody: some View {
        VStack {
            header
            
            Divider()
            
            if let spendings = snapshot.spendings {
                Section {
                    HStack {
                        Chart(spendings, id: \.accoundId) {
                            barMark($0.accountName, $0.total, $0.total / sumOfSpending)
                        }
                        .chartYScale(domain: [0, 1.1 * sumOfSpending])
                        
                        Chart(spendings, id: \.accoundId) {
                            sectorMark($0.accountName, $0.total, $0.total / sumOfSpending)
                        }
                    }
                } header: {
                    HStack {
                        Text("SPENDING")
                            .font(.title3)
                        Spacer()
                    }
                }
                .padding()
            }
            
            if let incomes = snapshot.incomes {
                Section {
                    HStack {
                        Chart(incomes, id: \.accoundId) {
                            barMark($0.accountName, $0.total, $0.total / sumOfIncome)
                        }
                        .chartYScale(domain: [0, 1.1 * sumOfIncome])
                        
                        Chart(incomes, id: \.accoundId) {
                            sectorMark($0.accountName, $0.total, $0.total / sumOfIncome)
                        }
                    }
                } header: {
                    HStack {
                        Text("INCOME")
                            .font(.title3)
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .frame(width: 540.0, height: 700.0)
    }
}
