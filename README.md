# TodoList DB2 backend

[![Swift 3 6-06](https://img.shields.io/badge/Swift%203-6/20 SNAPSHOT-blue.svg)](https://swift.org/download/#snapshots)

> A [Swift DB2](https://github.com/IBM-DTeam/swift-for-db2) implementation of the TodoList backend

## Quick start:

1. Download and install the [Swift DEVELOPMENT 06-20 snapshot](https://swift.org/download/#snapshots) Make sure you update your toolchain and path, as described in the install instructions.

2. Install dependencies:

  macOS: 
  `brew install wget unixodbc`
  
  Linux: 
  `sudo apt-get update`
  `sudo apt-get install -y clang unixodbc-dev unzip wget tar`
  
3. Install the DB2 system driver:

  `wget https://github.com/IBM-DTeam/swift-for-db2-cli/archive/master.zip && unzip master.zip && cd swift-for-db2-cli-master && sudo ./cli.sh && . env.sh && cd .. && rm -f master.zip && rm -rf swift-for-db2-cli-master`
  
4. (Linux only) Clone, build and install the libdispatch library. The complete instructions for building and installing this library are here, though, all you need to do is just this: 

 `git clone -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git && cd swift-corelibs-libdispatch && git submodule init && git submodule update && sh ./autogen.sh && ./configure --with-swift-toolchain=<path-to-swift>/usr --prefix=<path-to-swift>/usr && make && make install`
  
5. Clone the repository:
 
  `git clone https://github.com/IBM-Swift/todolist-db2`

6. Clone the test cases

  `git clone https://github.com/IBM-Swift/todolist-tests Tests`
  
7. Compile the application

  macOS: 
  `swift build -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib`
  
  Linux: 
  `swift build -Xcc -fblocks -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib`
  
8. Run the test cases with swift test

  `swift test`
  




