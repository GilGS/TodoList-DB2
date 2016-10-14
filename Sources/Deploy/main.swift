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

import Kitura
import HeliumLogger
import LoggerAPI
import CloudFoundryEnv
import TodoList

Log.logger = HeliumLogger()

let todos: TodoList

do {
    if let service = try CloudFoundryEnv.getAppEnv().getService(spec: "dashDB"){
        
        let driver: String, database: String, hostname: String, port: UInt16, uid: String, pwd: String
        
        driver = "{DB2}"
        
        if let credentials = service.credentials{
            database = credentials["db"].stringValue
            hostname = credentials["host"].stringValue
            port = UInt16(credentials["port"].stringValue)!
            uid = credentials["username"].stringValue
            pwd = credentials["password"].stringValue
            
        } else {
            database = "BLUDB"
            hostname = "bluemix05.bluforcloud.com"
            port = 50000
            uid = ""
            pwd = ""
        }

        let options = [String : AnyObject]()
        
        Log.verbose("Found TodoList-DB2")
        todos = TodoList(driver: driver, database: database, hostname: hostname, port: port, uid: uid, pwd: pwd)

    } else {
        Log.info("Could not find Bluemix DB2 service")
        todos = TodoList()
    }
    
    let controller = TodoListController(backend: todos)
    
    let port = try CloudFoundryEnv.getAppEnv().port
    Log.verbose("Assigned port is \(port)")
    
    Kitura.addHTTPServer(onPort: port, with: controller.router)
    Kitura.run()
    
} catch CloudFoundryEnvError.InvalidValue {
    Log.error("Oops... something went wrong. Server did not start.")
}
