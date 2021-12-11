//
//  ConverterController.swift
//  CurrencyCourses
//
//  Created by Александр Касьянов on 15.09.2021.
//

import UIKit

class ConverterController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var labelCoursesForDate: UILabel!
    @IBOutlet weak var buttonFrom: UIButton!
    @IBOutlet weak var buttonTo: UIButton!
    @IBOutlet weak var textFrom: UITextField!
    @IBOutlet weak var textTo: UITextField!
    @IBOutlet weak var buttonDone: UIBarButtonItem!
    @IBAction func pushDoneAction(_ sender: Any) {
        //скрываем клавиатуру
        textFrom.resignFirstResponder()
        //скрываем кнопку
        navigationItem.rightBarButtonItem = nil
    }
    @IBAction func pushFromAction(_ sender: Any) {
        //обращаемся к navigation controller
        let nc = storyboard?.instantiateViewController(withIdentifier: "selectedCurrencyNSID") as! UINavigationController
        //обращаемся к элементу navigation controller
        (nc.viewControllers[0] as! SelectCurrencyController).flagCurrency = .from
        //меняем отображение на fullScreen для корректной отработки метода viewWillAppear
        nc.modalPresentationStyle = .fullScreen
        //отображаем элемент
        present(nc, animated: true, completion: nil)
    }
    @IBAction func pushToAction(_ sender: Any) {
        //обращаемся к navigation controller
        let nc = storyboard?.instantiateViewController(withIdentifier: "selectedCurrencyNSID") as! UINavigationController
        //обращаемся к элементу navigation controller
        (nc.viewControllers[0] as! SelectCurrencyController).flagCurrency = .to
        //меняем отображение на fullScreen для корректной отработки метода viewWillAppear
        nc.modalPresentationStyle = .fullScreen
        //отображаем элемент
        present(nc, animated: true, completion: nil)
    }
    @IBAction func textFromEditingChanged(_ sender: Any) {
        let amount = Double(textFrom.text!)
        textTo.text = Model.shared.convert(amount: amount)
    }
    //обновление информации о конвертируемых валютах
    func refreshButtons() {
        buttonFrom.setTitle(Model.shared.fromCurrency.charCode, for: UIControl.State.normal)
        buttonTo.setTitle(Model.shared.toCurrency.charCode, for: UIControl.State.normal)
    }
    
    //метод вызывается, когда начинается редактирование поля
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //показываем кнопку при редактировании кнопки
        navigationItem.rightBarButtonItem = buttonDone
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //кнопки обновляются перед появлением вью
        refreshButtons()
        //пересчитываем значения при смене валюты
        textFromEditingChanged(self)
        //отображаем дату курсв
        labelCoursesForDate.text = "Курсы за дату: \(Model.shared.currentDate)"
        //скрываем кнопку Done после выбора валюты
        navigationItem.rightBarButtonItem = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //показываем кнопку после скрытия клавиатуры
        textFrom.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
