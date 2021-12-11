//
//  CoursesController.swift
//  CurrencyCourses
//
//  Created by Александр Касьянов on 14.09.2021.
//

import UIKit

class CoursesController: UITableViewController {
    @IBAction func pushRefreshAction(_ sender: Any) {
        Model.shared.loadXMLFile(date: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //отлавливаем уведомление о загрузке XML-файла
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "startLoadingXML"), object: nil, queue: nil) { (notification) in
            //обновляем данные на экране в основном потоке
            DispatchQueue.main.async {
                //создаём индикатор загрузки
                let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
                //запуск индикатора
                activityIndicator.startAnimating()
                //добавляем индикатор на панель
                self.navigationItem.rightBarButtonItem?.customView = activityIndicator
            }
        }
        //отлавливаем уведомление об обновлении данных
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "dataRefreshed"), object: nil, queue: nil) { (notification) in
            //обновляем данные на экране в основном потоке
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.navigationItem.title = Model.shared.currentDate
                //возвращаем кнопку обновления после загрузки данных
                let barButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(self.pushRefreshAction(_:)))
                //добавляем кнопку на панель
                self.navigationItem.rightBarButtonItem = barButtonItem
            }            
        }
        //обработка уведомления об ошибке
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ErrorLoadingXML"), object: nil, queue: nil) { (notification) in
            //получаем название ошибки
            let errorName = notification.userInfo?["ErrorName"]
            print(errorName as Any)
            //возвращаем кнопку
            DispatchQueue.main.async {
                //создаём алерт
                let alert = UIAlertController(title: "Ошибка", message: errorName as? String, preferredStyle: .alert)
                //кнопка алерта
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                //добавляем кнопку к алерту
                alert.addAction(alertAction)
                //отображаем алерт
                self.present(alert, animated: true, completion: nil)
                
                //возвращаем кнопку обновления после загрузки данных
                let barButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(self.pushRefreshAction(_:)))
                //добавляем кнопку на панель
                self.navigationItem.rightBarButtonItem = barButtonItem
            }
        }
        //вывод текущей даты на экран
        navigationItem.title = Model.shared.currentDate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //тест на запись данных по ссылке
        Model.shared.loadXMLFile(date: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //количество столбцов
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //количество строк в таблице
        return Model.shared.currencies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //обращение к ячейке в viewController
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CourseCell
        //получеам курс для соответствующей ячейки
        let courseForCell = Model.shared.currencies[indexPath.row]
//        //запись названия валюты в ячейку
//        cell.textLabel?.text = courseForCell.name
//        //запись номинала валюты в ячейку
//        cell.detailTextLabel?.text = courseForCell.value
        //запись занчения и изображения в ячейку
        cell.initCell(currency: courseForCell)
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
