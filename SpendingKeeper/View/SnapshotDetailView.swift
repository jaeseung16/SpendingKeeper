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
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif
    
    @State var snapshot: SKSnapshot
    @State private var presentShareSheet = false
    @State private var records: [SKSnapshotRecord]
    @State private var sortOrder = [KeyPathComparator(\SKSnapshotRecord.recordDate)]
    
    private var sumOfIncome: Double
    private var sumOfSpending: Double
    
    init(snapshot: SKSnapshot) {
        self.snapshot = snapshot
        
        self.sumOfIncome = snapshot.incomes?.map { $0.total }.reduce(0.0, +) ?? 0.0
        self.sumOfSpending = snapshot.spendings?.map { $0.total }.reduce(0.0, +) ?? 0.0
        
        self.records = snapshot.records ?? [SKSnapshotRecord]()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                header
                
                Divider()
                
                if let spendings = snapshot.spendings {
                    spendingCharts(spendings)
                        .padding()
                }
                
                if let incomes = snapshot.incomes {
                    incomeCharts(incomes)
                        .padding()
                }
                
                recordTable
                    .frame(minHeight: 0.3 * geometry.size.height, maxHeight: 0.5 * geometry.size.height)
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
    
    private func spendingCharts(_ spendings: [SKSnapshotSpending]) -> some View {
        Section {
            HStack {
                SnapshotCharts(data: spendings)
            }
        } header: {
            HStack {
                Text("SPENDING")
                    .font(.title3)
                Spacer()
            }
        }
    }
    
    private func incomeCharts(_ incomes: [SKSnapshotIncome]) -> some View {
        Section {
            HStack {
                SnapshotCharts(data: incomes)
            }
        } header: {
            HStack {
                Text("INCOME")
                    .font(.title3)
                Spacer()
            }
        }
    }
    
    private var recordTable: some View {
        Table(records, sortOrder: $sortOrder) {
            TableColumn("Date", value: \.recordDate) {
                firstColumn($0)
            }
            
            TableColumn("Account", value: \.accountName)
            
            TableColumn("Income/Spending", value: \.transactionType.rawValue)
            
            TableColumn("Description", value: \.recordDescription)
            
            TableColumn("Amount", value: \.amount) {
                Text($0.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                    .foregroundColor(.primary)
            }
            .alignment(.numeric)
        }
        .onChange(of: sortOrder) { _, sortOrder in
            records.sort(using: sortOrder)
        }
    }
    
    private func firstColumn(_ record: SKSnapshotRecord) -> some View {
        VStack(alignment: .leading) {
            if isCompact {
                Text(record.recordDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .foregroundColor(.secondary)
                HStack {
                    Text(record.amount, format: .currency(code: Locale.current.currency?.identifier ?? ""))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(record.recordDescription)
                }
            } else {
                Text(record.recordDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var recordGrid: some View {
        List {
            Grid(alignment: .leading) {
                GridRow {
                    Text("Date")
                    Text("Account")
                    Text("Income/Spending")
                    Text("Description")
                    Text("Amount")
                }
                .bold()
                Divider()
                ForEach(records.sorted(by: {$0.recordDate < $1.recordDate})) { record in
                    SnapshotRecordView(record: record)
                }
                
            }
        }
    }
    
    private var pageHeader: some View {
        VStack {
            HStack {
                Text("Date")
                    .frame(width: 108)
                Text("Account")
                    .frame(width: 108)
                Text("Income/Spending")
                    .frame(width: 108)
                    .multilineTextAlignment(.center)
                Text("Description")
                    .frame(width: 108)
                Text("Amount")
                    .frame(width: 108)
            }
            .bold()
            
            Divider()
        }
        .frame(width: 540.0)
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
        
        // Charts in first page
        renderFirstPage(pdf, in: box)
        
        // Table from second page
        renderRecordTable(pdf, in: box)
        
        pdf.closePDF()
        
        return url
    }
    
    private func renderFirstPage(_ pdf: CGContext, in box: CGRect) {
        pdf.beginPDFPage(nil)
        
        let renderer = ImageRenderer(content: SnapshotPDFFirstPageView(snapshot: snapshot))
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
    }
    
    private func renderRecordTable(_ pdf: CGContext, in box: CGRect) {
        let sortedRecords = records.sorted(by: { $0.recordDate < $1.recordDate })
        var index = 0
        
        while index < records.count {
            pdf.beginPDFPage(nil)
            
            var yPosition = 0.0
            
            let headerRenderer = ImageRenderer(content: pageHeader)
            headerRenderer.render { size, renderer in
                let xTranslation = box.size.width / 2.0 - size.width / 2.0
                let yTranslation = box.size.height - 108.0 // 1.5 inch from the top
                yPosition += 108.0
                pdf.translateBy(x: xTranslation, y: yTranslation)
                
                renderer(pdf)
            }
            
            while yPosition < 700.0 && index < records.count {
                let rowRenderer = ImageRenderer(content: SnapshotRecordView(record: sortedRecords[index]))
                rowRenderer.render { size, renderer in
                    let xTranslation = 0.0
                    let yTranslation = -1.5 * size.height // 1.5 spacing
                    yPosition += 1.5 * size.height
                    pdf.translateBy(x: xTranslation, y: yTranslation)
                    renderer(pdf)
                }
                
                index += 1
            }
            
            pdf.endPDFPage()
        }
    }
}
