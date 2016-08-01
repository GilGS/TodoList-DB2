/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import TodoListAPI

import IBMDB

/**
 
 The DB2/dashDB database should have a table with the following schema:
 
 CREATE TABLE "todos"
 (
 "todoid" 	INT             NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
 "title" 	VARCHAR(256) 	NOT NULL,
 "ownerid" VARCHAR(128) 	NOT NULL,
 "completed" INT 			NOT NULL,
 "orderno"	INT 			NOT NULL
 );
 */

public class TodoList : TodoListAPI {
    
    let db = IBMDB()
    let connString = "DRIVER={DB2};DATABASE=BLUDB;HOSTNAME=bluemix05.bluforcloud.com;PORT=50000;UID=dash012876;PWD=GZcBgcw99LTa"
    //let connString : String
    
    static let defaultDriver = "{DB2}"
    static let defaultDatabase = "BLUDB"
    static let defaultHostname = "bluemix05.bluforcloud.com"
    static let defaultPort : UInt16 = 50000
    static let defaultUid = ""
    static let defaultPwd = ""
    
    public init(_ dbConfiguration: DatabaseConfiguration) {
        
        let connStringArray = ["DRIVER="+TodoList.defaultDriver,
                               "DATABASE="+TodoList.defaultDatabase,
                               "HOSTNAME="+String(dbConfiguration.host),
                               "PORT="+String(dbConfiguration.port),
                               "UID="+String(dbConfiguration.username),
                               "PWD="+String(dbConfiguration.password)]
        
        //connString = connStringArray.joined(separator: ";")
        
    }
    
    public init(driver: String = TodoList.defaultDriver,
                database: String = TodoList.defaultDatabase,
                hostname: String = TodoList.defaultHostname,
                port: UInt16 = TodoList.defaultPort,
                uid: String = defaultUid,
                pwd: String = defaultPwd) {
        
        let connStringArray = ["DRIVER="+driver, "DATABASE="+database, "HOSTNAME="+hostname, "PORT="+String(port), "UID="+uid, "PWD="+pwd]
        //connString = connStringArray.joined(separator: ";")

    }
    
    public func count(withUserID: String?, oncompletion: (Int?, ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            let query = "SELECT * FROM \"todos\" WHERE \"ownerid\"=\'\(userParameter)\'"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                oncompletion(result.count, nil)
            }
        }
    }
    
    public func clear(withUserID: String?, oncompletion: (ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            let query = "DELETE from \"todos\" WHERE \"ownerid\"=\'\(userParameter)\'"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(TodoCollectionError.ConnectionRefused)
                    return
                }
                
                oncompletion(nil)
            }
        }
    }
    
    public func clearAll(oncompletion: (ErrorProtocol?) -> Void) {
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            let query = "TRUNCATE TABLE \"todos\" IMMEDIATE"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(TodoCollectionError.ConnectionRefused)
                    return
                }
                oncompletion(nil)
            }
        }
    }
    
    public func get(withUserID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection -> Void in
            
            guard error == nil else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            let query = "SELECT * FROM \"todos\" WHERE \"ownerid\"=\'\(userParameter)\' ORDER BY \"orderno\" DESC"
            
            connection.query(query: query) {
                results, error in
                
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                do {
                    let todos = try self.parseTodoItemList(results: results)
                    oncompletion(todos, nil)
                }
                catch {
                    oncompletion(nil, TodoCollectionError.ParseError)
                }
            }
        }
    }
    
    public func get(withUserID: String?, withDocumentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection -> Void in
            
            guard error == nil else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            let query = "SELECT * FROM \"todos\" WHERE \"ownerid\"=\'\(userParameter)\' AND \"todoid\"=\'\(withDocumentID)\'"
            
            connection.query(query: query) {
                results, error in
                
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                do {
                    let todos = try self.parseTodoItemList(results: results)
                    oncompletion(todos[0], nil)
                    
                }catch {
                    oncompletion(nil, TodoCollectionError.ParseError)
                }
            }
        }
    }

    public func add(userID: String?, title: String, order: Int, completed: Bool,
             oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let userParameter = userID ?? "default"
 
        db.connect(info: connString){
            error, connection -> Void in
	               
            guard error == nil else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
             
            guard let connection = connection else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
          
            let completedValue = completed ? 1 : 0
            
            let query =
                "INSERT INTO \"todos\" (\"title\", \"ownerid\", \"completed\", \"orderno\") VALUES(\'\(title)\', \'\(userParameter)\', \(completedValue), \(order))"
            
            connection.query(query: query) {
                result, error in
      
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                let selectQuery = "SELECT IDENTITY_VAL_LOCAL() AS id FROM \"todos\""
                connection.query(query: selectQuery) {
                    result1, error1 in
                              
print("inside query closure 2")         
                    #if os(OSX)
                        let documentID = result1[0][0]["ID"]
                        #else
print("inside #else block")
print("before test assignment")
                        let documentID = result1[0][0]["ID" as! AnyObject]
print("after let statement")
                        #endif
                        
                    
                    let addedItem = TodoItem(documentID: String(documentID!), userID: userParameter, order: order, title: title, completed: completed)
                    oncompletion(addedItem, nil)
                }
            }
        }
    }
    
    public func update(documentID: String, userID: String?, title: String?, order: Int?,
                completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let user = userID ?? "default"
        
        var originalTitle: String = "", originalOrder: Int = 0, originalCompleted: Bool = false
        var titleQuery: String = "", orderQuery: String = "", completedQuery: String = ""
        
        get(withUserID: userID, withDocumentID: documentID){
            todo, error in
            
            if let todo = todo {
                originalTitle = todo.title
                originalOrder = todo.order
                originalCompleted = todo.completed
            }
            
            let finalTitle = title ?? originalTitle
            if (title != nil) {
                titleQuery = " \"title\"=\'\(finalTitle)\',"
            }
            
            let finalOrder = order ?? originalOrder
            if (order != nil) {
                orderQuery = " \"orderno\"=\'\(finalOrder)\',"
            }
            
            let finalCompleted = completed ?? originalCompleted
            if (completed != nil) {
                let completedValue = finalCompleted ? 1 : 0
                completedQuery = " \"completed\"=\'\(completedValue)\',"
            }
            
            var concatQuery = titleQuery + orderQuery + completedQuery
            
            let query = "UPDATE \"todos\" SET" + String(concatQuery.characters.dropLast()) + " WHERE \"todoid\"=\'\(documentID)\'"
            
            self.db.connect(info: self.connString) {
                error, connection in
                
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                guard let connection = connection else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                connection.query(query: query) {
                    result, error in
                    
                    guard error == nil else {
                        oncompletion(nil, TodoCollectionError.ConnectionRefused)
                        return
                    }
                    
                    let updatedItem = TodoItem(documentID: documentID, userID: user, order: finalOrder,
                                               title: finalTitle, completed: finalCompleted)
                    oncompletion(updatedItem, nil)
                }
            }
        }
    }
    
    public func delete(withUserID: String?, withDocumentID: String, oncompletion: (ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            let query = "DELETE FROM \"todos\" WHERE \"ownerid\"=\'\(userParameter)\' AND \"todoid\"=\'\(withDocumentID)\'"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(TodoCollectionError.ConnectionRefused)
                    return
                }
                
                oncompletion(nil)
            }
        }
    }
    
    private func parseTodoItemList(results: [[NSDictionary]]) throws -> [TodoItem] {
        
        var todos = [TodoItem]()
        for entry in results {
            
            let item: TodoItem = try createTodoItem(entry: entry)
            todos.append(item)
        }
        
        return todos
    }
    
    private func createTodoItem(entry: [NSDictionary]) throws -> TodoItem {
        
        var documentID: Int = 0, userID: String = "", title: String = "", orderno: Int = 0, completed: Int = 0
        
        for element in entry {
            #if os(OSX)
                if let e1 = element.value(forKey: "todoid"){
                    documentID = e1.intValue
                    continue
                }
                if let e2 = element.value(forKey: "ownerid") {
                    userID = e2 as! String
                    continue
                }
                if let e3 = element.value(forKey: "title") {
                    title = e3 as! String
                    continue
                }
                if let e4 = element.value(forKey: "orderno") {
                    orderno = e4.intValue
                    continue
                }
                if let e5 = element.value(forKey: "completed") {
                    completed = e5.intValue
                    continue
                }
            
            #else
                /*if let e1 = element["todoid" as! AnyObject]{
                    documentID = 1 //e1 as! Int
                    continue
                }
                if let e2 = element["ownerid" as! AnyObject] {
                    userID = "2" //e2 as! String
                    continue
                }
                if let e3 = element["title" as! AnyObject] {
                    title = "3" //e3 as! String
                    continue
                }
                if let e4 = element["orderno" as! AnyObject] {
                    orderno = 4 //e4 as! Int
                    continue
                }
                if let e5 = element["completed" as! AnyObject] {
                    completed = 5 // e5 as! Int
                    continue
                }*/
            #endif
            
        }
        
        let completedValue = completed == 1 ? true : false
        let todoItem = TodoItem(documentID: String(documentID), userID: userID, order: orderno, title: title, completed: completedValue)
        
        return todoItem
    }
}

