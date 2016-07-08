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
        
        db.connect(info: connString) { (error, connection) -> Void in
            if error != nil {
                print(error)
            } else {
                print("Connected to the database!")
                
                let query = "SELECT * FROM 'todos' WHERE 'ownerid'='bob'"
                
                connection!.query(query: query) { (result, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        print(result)
                        
                        oncompletion(1, nil)
                    }
                }
                
            }
        }
        
    }
    
    func clear(withUserID: String?, oncompletion: (ErrorProtocol?) -> Void) {
        let query = "DELETE from todos WHERE ownerid=\(withUserID)"
    }
    
    func clearAll(oncompletion: (ErrorProtocol?) -> Void) {
        let query = "TRUNCATE TABLE todos"
    }
    
    func get(withUserID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {
        let query = "SELECT * FROM todos WHERE ownerid=\(withUserID)"
    }
    
    func get(withUserID: String?, withDocumentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        let query = "SELECT * FROM todos WHERE ownerid=\(withUserID) AND todoid=\(withDocumentID)"
    }
    
    func add(userID: String?, title: String, order: Int, completed: Bool,
             oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let query = "INSERT INTO todos (title, ownerid, completed, orderno) VALUES (\(title), \(userID), \(completed), \(order));"
        
    }
    
    func update(documentID: String, userID: String?, title: String?, order: Int?,
                completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        // This requires a more selective update statement than just completed
        
        let query = "UPDATE todos SET completed=\(completed) WHERE todoid=\(documentID)"
        
    }
    
    func delete(withUserID: String?, withDocumentID: String, oncompletion: (ErrorProtocol?) -> Void) {
        
        let query = "DELETE FROM todos WHERE ownerid=\(withUserID) AND todoid=\(withDocumentID)"
        
    }
    
}