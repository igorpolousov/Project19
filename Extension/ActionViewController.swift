//
//  ActionViewController.swift
//  Extension
//  Day 67-69
//  Created by Igor Polousov on 12.11.2021.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    
    // Переменная для UITextView
    @IBOutlet var script: UITextView!
    
    // Переменные для хранения названия и адреса станицы
    var pageTitle = ""
    var pageURL = ""
    
    // Массив для сохранения скриптов по имени от пользователя
    var savedScriptsName = [UserScript]()
    // Массив для сохранения скриптов по имени хоста
    var savedScriptURL = [UserScript]()
    // Переменная для получения текста из таблицы сохраненных скриптов
    var scriptToLoad: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(savedScriptsName)
        
        // Получение текста скрипта из таблицы сохраненных скриптов
        if let scriptReceived = scriptToLoad {
            script.text = scriptReceived
        }
        
        // Правая кнопка в navigation controller с selector done()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        // Левая кнопка навигации
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(chooseAction))
        
        // Механизм который позволяет отправлять информацию для зарегистрированных наблюдателей
        let notificationCenter = NotificationCenter.default
        // Добавлен наблюдатель: сообщение непосредственно перед удалением клавиатуры с экрана
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Наблюдатель: сообщение непосредственно перед изменением формы клавитуры
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
        // Если есть содержимое на Extension view
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            // Если есть данные в массиве inputItem
            if let itemProvider = inputItem.attachments?.first {
                // Загружает данные и переводит их в требуемый тип данных
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    // Создаётся словарь значений
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    // Создаётся константа словарь с принимаемым значением
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    print(javaScriptValues)
                    
                    // Присваивание значения к переменным из полученного словаря
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    // Добавление title при появлении extension на экране
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        // Загрузка скрипта при открытии Extension в соотвествии с название хоста открытой страницы
                        self?.loadScriptURL()
                        
                    }
                }
            }
        }
    }

    
    
    // Кнопка done, нужна для передачи данных в файл Action.js
   @objc func done() {
       // Сохранение скрипта
       saveScriptURL()
        let item = NSExtensionItem()
       // Создан словарь который принимает значение с экрана UITextView
        let argument: NSDictionary = ["customJavaScript": script.text as Any]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    // Функция выбора действия левой кнопки
    @objc func chooseAction() {
        let ac = UIAlertController(title: "Choose action", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Examples", style: .default, handler: loadExamples))
        ac.addAction(UIAlertAction(title: "Load Script", style: .default, handler: loadScript))
        ac.addAction(UIAlertAction(title: "Save Script", style: .default, handler: saveScript))
        present(ac, animated: true)
    }
    
    // Функция загрузки примеров скриптов
    func loadExamples(action: UIAlertAction) {
        let ac = UIAlertController(title: "Scripts", message: "Choose script", preferredStyle: .actionSheet)
        for (title, exampleScript) in exampleScripts {
            ac.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.script.text = exampleScript
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    // Сохранение скрипта по имени хоста
    func saveScriptURL() {
        if let url = URL(string: pageURL) {
            if let host = url.host {
                let example = UserScript(title: host, exampleScript: script.text ?? "")
                savedScriptURL.append(example)
                saveURL()
            }
        }
    }
    // Сохранение скрипта по имени хоста в userDefaults
    func saveURL() {
        let defaults = UserDefaults.standard
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(savedScriptURL) {
            defaults.setValue(savedData, forKey: "URL")
        }
    }
    // Загрузка скрипта согласно выбранной страницы при запуске Extension
    func loadScriptURL() {
        loadURL()
        if let url = URL(string: pageURL){
            if let host = url.host {
                for object in savedScriptURL {
                    if object.title == host {
                        script.text = object.exampleScript
                    }
                }
            }
        }
    }
    // Загрузка скрипта при открытии Extension согласно имени хоста из UserDefaults
    func loadURL() {
        let defaults = UserDefaults.standard
        let jsonDecoder = JSONDecoder()
        
        if let savedData = defaults.object(forKey: "URL") as? Data {
            do {
                savedScriptURL = try jsonDecoder.decode([UserScript].self, from: savedData)
            } catch  {
                print("Failed to load data")
            }
        }
    }
    // Загрузка скрипта из таблицы для левой кнопки
    func loadScript(action: UIAlertAction) {
        loadName()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Load") as? LoadViewController {
            vc.savedScriptsName = savedScriptsName
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    // Загрузка скрипта из userDefaults для левой кнопки
    func loadName() {
        let defaults = UserDefaults.standard
        let jsonDecoder = JSONDecoder()
        if let savedData =  defaults.object(forKey: "Name") as? Data {
            do {
                savedScriptsName = try jsonDecoder.decode([UserScript].self, from: savedData)
            } catch  {
                print("Failed to load data")
            }
        }
    }
    
    // Сохранение скрипта для левой кнопки с возможностью указать имя скрипта
    func saveScript(action: UIAlertAction) {
        let ac = UIAlertController(title: "Name script", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Add", style: .default) {[weak self, weak ac] _ in
            guard let name = ac?.textFields?[0].text else { return }
            let example = UserScript(title: name, exampleScript: (self?.script.text) ?? "")
            self?.savedScriptsName.append(example)
            self?.saveName()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    // Сохранение скрипта для левой кнопки в UserDefaults
    func saveName() {
        let defaults = UserDefaults.standard
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(savedScriptsName) {
            defaults.setValue(savedData, forKey: "Name")
        }
    }
    
    // Метод сделан чтобы сдвигался экран с текстом при достижении поля с клавиатурой
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
}
