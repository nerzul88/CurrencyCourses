//
//  Model.swift
//  CurrencyCourses
//
//  Created by Александр Касьянов on 14.09.2021.
//

import UIKit

class Currency {
    var numCode: String?
    var charCode: String?
    var nominal: String?
    var nominalDouble: Double?
    var name: String?
    var value: String?
    var valueDouble: Double?
    
    //картинки флагов
    var imageFlag: UIImage? {
        if let charCode = charCode {
            return UIImage(named: charCode + ".png")
        }
        return nil
    }
    //создаём рубль
    class func rouble() -> Currency {
        let rub = Currency()
        rub.charCode = "RUR"
        rub.name = "Российский рубль"
        rub.nominal = "1"
        rub.nominalDouble = 1.0
        rub.value = "1"
        rub.valueDouble = 1.0
        return rub
    }
}

class Model: NSObject, XMLParserDelegate {
    //экземпляр класса для реализации содели singletone
    static let shared = Model()
    //массив для хранения валют
    var currencies: [Currency] = []
    //буфер для парсинга текущей валюты
    var currentCurrency: Currency?
    //буфер для значений текущей валюты
    var currentCharacters: String = ""
    //дата определённого курса
    var currentDate: String = ""
    //переменные для конвертации валюты
    var fromCurrency: Currency = Currency.rouble()
    var toCurrency: Currency = Currency.rouble()
    //пути для загрузки файлов
    var pathForXML: String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml"
        //проверка, существует ли файл, загруженный из сети
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
        //если не существует, то возвращаем имеющийся файл
        return Bundle.main.path(forResource: "data", ofType: "xml") ?? ""
    }
    var urlForXML: URL {
        return URL(fileURLWithPath: pathForXML)
    }
    
    //конвертация валют
    func convert(amount: Double?) -> String {
        if amount == nil {
            return ""
        }
        let result = ((fromCurrency.nominalDouble! * fromCurrency.valueDouble!) / (toCurrency.nominalDouble! * toCurrency.valueDouble!)) * amount!
        return String(result)
    }
    
    //загрузка XML с сайта cbr.ru и сохранение в каталоге приложения
    //http://www.cbr.ru/scripts/XML_daily.asp?date_req=02/03/2002
    func loadXMLFile(date: Date?) {
        //ссылка на ресурс для скачивания xml без даты
        var strUrl = "http://www.cbr.ru/scripts/XML_daily.asp?date_req="
        //проверка и добаление к ссылке даты
        if date != nil {
            //преобразование даты в требуемый формат
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            //добавляем текущую дату к ссылке
            strUrl += dateFormatter.string(from: date!)
        }
        //формирование ссылки
        let url = URL(string: strUrl)
        //запрос по ссылке в параллельном потоке
        let task = URLSession.shared.dataTask(with: url!) { (data, responce, error) in
            
            //обработка ошибки загрузки данных
            var errorGlobal: String?
            
            if error == nil {
                //сохраняем данные по заданному пути
                //путь для сохранения данных
                let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml"
                //ссылка для сохранения данных
                let urlForSave = URL(fileURLWithPath: path)
                //обрабатываем возможную ошибку записи данных
                do {
                    //записываем данные по ссылке
                    try data?.write(to: urlForSave)
                    print(path)
                    print("Файл загружен")
                    //перепарсиваем новый XML
                    self.parseXML()
                } catch {
                    print("Error saving data: \(error.localizedDescription)")
                    errorGlobal = error.localizedDescription
                }
            } else {
                //вывод на печать ошибки
                print("Error loading XML file: " + error!.localizedDescription)
                errorGlobal = error?.localizedDescription
            }
            //отображение ошибки в уведомлении
            if let errorGlobal = errorGlobal {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ErrorLoadingXML"), object: self, userInfo: ["ErrorName":errorGlobal])
            }
        }
        //отправка уведомления о загрузке XML-файла
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startLoadingXML"), object: self)
        task.resume()
    }
    //парсинг XML и помещение его в currencies: [Currency]
    //отправка уведомления приложение об обновлении данных
    func parseXML() {
        //обнуляем массив с данными для избежания повторения
        currencies = [Currency.rouble()]
        //создаём парсер с ссылкой на XML
        let parser = XMLParser(contentsOf: urlForXML)
        //назначаем делегат
        parser?.delegate = self
        //парсим
        parser?.parse()
        
        print("Данные обновлены")
        //отправка уведомления об обновлении данных по всему приложению
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataRefreshed"), object: self)
        //обновляем данные за конкретную дату для корректного отображения в конвертере
        for currency in currencies {
            if currency.charCode == fromCurrency.charCode {
                fromCurrency = currency
            }
            if currency.charCode == toCurrency.charCode {
                toCurrency = currency
            }
        }
    }
    //метод вызывается при нахождении совпадающего тега
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //проверка существования даты
        if elementName == "ValCurs" {
            //текущая дата
            if let currentDateString = attributeDict["Date"] {
                //присваиваем дату
                currentDate = currentDateString
            }            
        }
        
        //как только встречается текущий открывающий тег, создаётся новая валюта
        if elementName == "Valute" {
            currentCurrency = Currency()
        }
    }
    //метод вызывается при нахождении совпадающего тега
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //как только встречается закрывающий тег, новая валюта добавляется в массив валют
        switch elementName {
        case "Valute":
            currencies.append(currentCurrency!)
        case "NumCode":
            currentCurrency?.numCode = currentCharacters
        case "CharCode":
            currentCurrency?.charCode = currentCharacters
        case "Nominal":
            currentCurrency?.nominal = currentCharacters
            currentCurrency?.nominalDouble = Double(currentCharacters.replacingOccurrences(of: ",", with: "."))
        case "Name":
            currentCurrency?.name = currentCharacters
        case "Value":
            currentCurrency?.value = currentCharacters
            currentCurrency?.valueDouble = Double(currentCharacters.replacingOccurrences(of: ",", with: "."))
        default:
            break
        }
    }
    //метод вызывается при нахождении символов между открывающим и закрывающим тегами
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentCharacters = string
    }
}
