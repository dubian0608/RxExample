//
//  SimpleTableViewExampleSectionedController.swift
//  RxExample
//
//  Created by 张骥 on 2020/6/3.
//  Copyright © 2020 ZhangJi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SimpleTableViewExampleSectionedController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>(configureCell: { (_, tv, indexPath, item) -> UITableViewCell in
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\(item) @ row \(indexPath.row)"
        return cell
    }, titleForHeaderInSection: { (dataSource, sectionIndex) -> String? in
        return dataSource[sectionIndex].model
    }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = self.dataSource

        let items = Observable.just([
            SectionModel(model: "First section", items: [
                    1.0,
                    2.0,
                    3.0
                ]),
            SectionModel(model: "Second section", items: [
                    1.0,
                    2.0,
                    3.0
                ]),
            SectionModel(model: "Third section", items: [
                    1.0,
                    2.0,
                    3.0
                ])
            ])
        
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
        .map{ indexPath in
            return (indexPath, dataSource[indexPath])
        }
        .subscribe(onNext: { (pair) in
            DefaultWireframe.presentAlert("Tapped `\(pair.1)` @ \(pair.0)")
        })
        .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
        .disposed(by: disposeBag)

    }

}
