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
    let connString = "DRIVER={DB2};DATABASE=BLUDB;HOSTNAME=awh-yp-small02.services.dal.bluemix.net;PORT=50000;PROTOCOL=TCPIP;UID=dash111703;PWD=eb0b4bde1722;"
    
    func count(withUserID: String?, oncompletion: (Int?, ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(nil, error)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            //print("Connected to the database!")
            
            let query = "SELECT * FROM todos WHERE ownerid=\(userParameter)"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, error)
                    return
                }
                
                guard let result = result else{
                    //oncompletion error message
                    return
                }
                //print(result)
                
                oncompletion(result.count, nil)
            }
            
            
        }
        
    }
    
    func clear(withUserID: String?, oncompletion: (ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(error)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            //print("Connected to the database!")
            
            let query = "DELETE from todos WHERE ownerid=\(userParameter)"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(error)
                    return
                }
                
                oncompletion(nil)
            }
            
            
        }
    }
    
    func clearAll(oncompletion: (ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(error)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            //print("Connected to the database!")
            
            let query = "TRUNCATE TABLE todos"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(error)
                    return
                }
                
                
                oncompletion(nil)
            }
            
            
        }
    }
    
    func get(withUserID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(nil, error)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            //print("Connected to the database!")
            
            let query = "SELECT * FROM todos WHERE ownerid=\(userParameter) ORDER BY orderno DESC"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, error)
                    return
                }
                
                guard let result = result else{
                    //oncompletion error message
                    return
                }
                //print(result)
                
                let todos = parseTodoItemList(result)
                
                oncompletion(todos, nil)
            }
            
            
        }
    }
    
    func get(withUserID: String?, withDocumentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(nil, error)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            //print("Connected to the database!")
            
            let query = "SELECT * FROM todos WHERE ownerid=\(withUserID) AND todoid=\(withDocumentID)"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, error)
                    return
                }
                
                guard let result = result else{
                    //oncompletion error message
                    return
                }
                //print(result)
                
                let todos = parseTodoItemList(result)
                
                oncompletion(todos[0], nil)
            }
            
            
        }
        
    }
    
    func add(userID: String?, title: String, order: Int, completed: Bool,
             oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(nil, error)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            //print("Connected to the database!")
            
            
            let query = "INSERT INTO todos (title, ownerid, completed, orderno) VALUES(\(title), \(userID), \(completed), \(order));"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, error)
                    return
                }
                
                guard let result = result else{
                    //oncompletion error message
                    return
                }
                //print(result)
                
                let addedItem = TodoItem(documentID: result[0].value("todoid"), userID: user, order: order, title: title,
                                         completed: completedValue)
                
                oncompletion(result, nil)
            }
            
            
        }
        
    }
    
    func update(documentID: String, userID: String?, title: String?, order: Int?,
                completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        // This requires a more selective update statement than just completed
        
        var fieldsToUpdate : [Bool]  = [true, true, true]
        
        let user = userID ?? "default"
        
        guard let title = title else {
            fieldsToUpdate[0] = false
        }
        
        guard let order = order else {
            fieldsToUpdate[1] = false
        }
        
        guard let completed = completed else {
            fieldsToUpdate[2] = false
        }
        
        let query = "UPDATE todos SET"// completed=\(completed) WHERE todoid=\(documentID)"
        
        for i in (0..<fieldsToUpdate.count) where fieldsToUpdate[i]{
            switch i {
            case 0:
                query += "title=\(title)"
            case 1:
                query += "orderno=\(order)"
            case 2:
                query += "completed=\(completed)"
            }
            if (i != fieldsToUpdate.count - 1){
                query += ","
            }
        }
        
        query += "WHERE todoid=\(documentID)"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(nil, error)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            //print("Connected to the database!")
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(nil, error)
                    return
                }
                
                guard let result = result else{
                    //oncompletion error message
                    return
                }
                //print(result)
                
                let updatedItem = TodoItem(documentID: documentID, userID: user, order: order,
                                         title: title, completed: completed)
                
                oncompletion(updatedItem, nil)
            }
            
            
        }
        
        
    }
    
    func delete(withUserID: String?, withDocumentID: String, oncompletion: (ErrorProtocol?) -> Void) {
        
        let userParameter = withUserID ?? "default"
        
        db.connect(info: connString) {
            error, connection in
            
            guard error == nil else {
                oncompletion(error)
                return
            }
            
            guard let connection = connection else {
                //oncompletion error message
                return
            }
            
            //print("Connected to the database!")
            
            
            let query = "DELETE FROM todos WHERE ownerid=\(withUserID) AND todoid=\(withDocumentID)"
            
            connection.query(query: query) {
                result, error in
                
                guard error == nil else {
                    oncompletion(error)
                    return
                }
                
                oncompletion(nil)
            }
            
            
        }
        
    }
    
    func parseTodoItemList(dictionary: NSDictionary) throws -> [TodoItem] {
        
        var todos = [TodoItem]()
        for entry in dictionary {
            
            guard let id = entry.value("todoid"), let user = entry.value("ownerid"),
                let title = entry.value("title"), let completed = entry.value("completed"),
                let order = entry.value("orderno") else{
                    return nil
                    
            }
            
            todos.append(TodoItem(documentID: id, userID: user, order: order, title: title,
                                  completed: completedValue))
            
        }
        return todos
    }
    
}