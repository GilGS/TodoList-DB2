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
 "todoid" 	INT 			INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
 "title" 	VARCHAR(256) 	NOT NULL,
 "ownerid" VARCHAR(128) 	NOT NULL,
 "completed" INT 			NOT NULL,
 "orderno"	INT 			NOT NULL
 );
 */

struct TodoList : TodoListAPI {
    
    let db = IBMDB()
    let connString = "DRIVER={DB2};DATABASE=BLUDB;HOSTNAME=awh-yp-small02.services.dal.bluemix.net;PORT=50000;UID=dash111703;PWD=eb0b4bde1722"
    
    //let connString = "DRIVER={DB2};DATABASE=BLUDB;UID=dash6435;PWD=0NKUFZxcskVZ;HOSTNAME=dashdb-entry-yp-dal09-09.services.dal.bluemix.net;PORT=50000"
    
    static let defaultHost = ""
    static let defaultPort : UInt16 = 50000
    static let defaultHostname = "awh-yp-small02.services.dal.bluemix.net"
    static let defaultDatabase = "BLUDB"
    static let defaultUsername = ""
    static let defaultPassword = ""
    
    public init(_ dbConfiguration: DatabaseConfiguration) {
        
        print("in init1")
    }
    
    public init(database: String = TodoList.defaultDatabase, host: String = TodoList.defaultHost,
                port: UInt16 = TodoList.defaultPort,
                username: String? = defaultUsername, password: String? = defaultPassword) {
        
        print("in init2")
        
    }
    
    public init() {
        print("in init3")
    }
    
    func count(withUserID: String?, oncompletion: (Int?, ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            print("Connected to the database!")
            
            let query = "SELECT * FROM todos WHERE ownerid=\(userParameter)"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                
                print(result)
                
                oncompletion(result.count, nil)
            }
            
            
        }
        
    }
    
    func clear(withUserID: String?, oncompletion: (ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            print("Connected to the database!")
            
            let query = "DELETE from todos WHERE ownerid=\(userParameter)"
            
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
    
    func clearAll(oncompletion: (ErrorProtocol?) -> Void) {
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            print("Connected to the database!")
            
            let query = "TRUNCATE TABLE todos"
            
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
    
    func get(withUserID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        print(".... in getAll")
        
        
        db.connect(info: connString) {
            error, connection -> Void in
            
            if error != nil {
                print("***error! \(error)")
            } else {
                print("Connected to the database!")
            }
            
            guard error == nil else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            print("Connected to the database!")
            
            let query = "SELECT * FROM todos WHERE ownerid=\(userParameter) ORDER BY orderno DESC"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                print(result)
                
                //let todos = try parseTodoItemList(dictionary: result)
                //oncompletion(todos, nil)
                oncompletion(nil, nil)
                
            }
            
        }
    }
    
    func get(withUserID: String?, withDocumentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        print(".... in get")
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection -> Void in
            
            guard error == nil else {
                print("error: \(error)")
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            let query = "SELECT * FROM \"todos\" WHERE \"ownerid\"=\'\(userParameter)\' AND \"todoid\"=\'\(withDocumentID)\'"
            
            print("get query \(query)")
            
            connection.query(query: query) {
                results, error in
                
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                print("get result \(results)")
                
                do {
                    let todos = try self.parseTodoItemList(results: results)
                    oncompletion(todos[0], nil)
                    
                }catch {
                    
                }
                
                //oncompletion(nil, nil)
            }
            
            
        }
        
    }
    
    func add(userID: String?, title: String, order: Int, completed: Bool,
             oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        print(".... in add")
        
        let userParameter = userID ?? "default"
        
        db.connect(info: connString) {
            error, connection -> Void in
            
            guard error == nil else {
                print("error: \(error)")
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            let completedValue = completed ? 1 : 0
            
            let query = "INSERT INTO \"todos\" (\"title\", \"ownerid\", \"completed\", \"orderno\") VALUES(\'\(title)\', \'\(userParameter)\', \(completedValue), \(order))"
            
            print("query: \(query)")
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    print ("error: \(error)")
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                let selectQuery = "SELECT IDENTITY_VAL_LOCAL() AS id FROM \"todos\""
                connection.query(query: selectQuery) {
                    result1, error1 in
                    
                    let documentID = result1[0][0]["ID"]
                    
                    let addedItem = TodoItem(documentID: String(documentID!), userID: userParameter, order: order, title: title, completed: completed)
                    
                    print("new todo in add: \(addedItem)")
                    oncompletion(addedItem, nil)
                }
            }
        }
    }
    
    func update(documentID: String, userID: String?, title: String?, order: Int?,
                completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        // This requires a more selective update statement than just completed
        
        var fieldsToUpdate : [Bool]  = [true, true, true]
        
        let user = userID ?? "default"
        
        if title == nil {
            fieldsToUpdate[0] = false
        }
        
        if order == nil {
            fieldsToUpdate[1] = false
        }
        
        if completed == nil {
            fieldsToUpdate[2] = false
        }
        
        var query = "UPDATE todos SET"// completed=\(completed) WHERE todoid=\(documentID)"
        
        for i in (0..<fieldsToUpdate.count) where fieldsToUpdate[i]{
            switch i {
            case 0:
                query += "title=\(title)"
            case 1:
                query += "orderno=\(order)"
            case 2:
                query += "completed=\(completed)"
            default:
                continue
                
            }
            if (i != fieldsToUpdate.count - 1){
                query += ","
            }
        }
        
        query += "WHERE todoid=\(documentID)"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(nil, TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            print("Connected to the database!")
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, TodoCollectionError.ConnectionRefused)
                    return
                }
                
                print(result)
                
                let updatedItem = TodoItem(documentID: documentID, userID: user, order: order!,
                                           title: title!, completed: completed!)
                
                oncompletion(updatedItem, nil)
            }
            
            
        }
        
        
    }
    
    func delete(withUserID: String?, withDocumentID: String, oncompletion: (ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(TodoCollectionError.ConnectionRefused)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            print("Connected to the database!")
            
            
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
        
//        print ("entry!! \(entry)")
        
        for element in entry {
            if let e1 = element.value(forKey: "todoid"){
                documentID = e1.intValue
                print("found todoid")
                continue
            }
            if let e2 = element.value(forKey: "ownerid") {
                userID = e2 as! String
                print("found ownerid: \(userID)")
                continue
            }
            if let e3 = element.value(forKey: "title") {
                title = e3 as! String
                print("found title")
                continue
            }
            if let e4 = element.value(forKey: "orderno") {
                orderno = e4.intValue
                print("found orderno")
                continue
            }
            if let e5 = element.value(forKey: "completed") {
                completed = e5.intValue
                print("found completed")
                continue
            }
            
        }
        
        let completedValue = false //completed == 1 ? true : false
//
//        print("found owneridbbbb: \(userID)")
        let todoItem = TodoItem(documentID: String(documentID), userID: userID, order: orderno, title: title, completed: completedValue)
        print("newly created item: \(todoItem)")
        return todoItem
    }
    
}

