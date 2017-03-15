# issue_tls_block_reserve

An issue related to crypto/tls.(\*block).reserve

## Overview

The memory usage of crypto/tls.(\*block).reserve is increased linearly when https clients make a connection to a https server, then they never close its connection even if they wouldn't send/read data. But this is not a bug since the https server doesn't kwno whether https clients are live or not.

## Experience

Use Server.IdleTimeout in go 1.8.

## How to reproduce

Get code to reproduce and build.

    $ git clone https://github.com/t2y/issue_tls_block_reserve.git
    $ bash build.sh

Open 3 terminals to monitor server, client, pprof.

### Terminal 1

Start up https server.

    $ cd https_server
    $ ./server_main 
    2017/03/15 15:47:36 called FreeOSMemory()
    2017/03/15 15:47:39 called FreeOSMemory()
    ...

This https server calls `debug.FreeOSMemory()` every 3 seconds, then outputs.

### terminal 2

Start up https client without closing its connection. These clients sleeps 24 hours not to close the connection after requesting to the https server.

    $ cd https_client
    $ bash start_clients.sh 300 0.1
    start client to 300 every 0.1 seconds
    target server/port: localhost:4443
    client 1 is running
    client 2 is running
    client 3 is running
    ...

Stop https clients when you would confirmed.

    $ bash stop_clients.sh 
    all client_main processes are killed

### terminal 3

After the https server/clients started, you can confirm server status to get pprof result every 3 seconds. `crypto/tls.(*block).reserve` size increases with the increasing https client connections.

    $ bash get_pprof.sh 
    target server/port: localhost:4443
    run date: 2017-03-15 16:18:35
    connection: 46
    Fetching profile from http://localhost:6060/debug/pprof/heap
    Saved profile in /path/to/pprof/pprof.localhost:6060.inuse_objects.inuse_space.139.pb.gz
    1026.19kB of 1026.19kB total (  100%)
    Dropped 120 nodes (cum <= 5.13kB)
          flat  flat%   sum%        cum   cum%
         514kB 50.09% 50.09%      514kB 50.09%  net/http.newBufioWriterSize
      512.19kB 49.91%   100%   512.19kB 49.91%  runtime.malg
             0     0%   100%      514kB 50.09%  net/http.(*conn).serve
             0     0%   100%      514kB 50.09%  runtime.goexit
             0     0%   100%   512.19kB 49.91%  runtime.newproc.func1
             0     0%   100%   512.19kB 49.91%  runtime.newproc1
             0     0%   100%   512.19kB 49.91%  runtime.startTheWorldWithSema
             0     0%   100%   512.19kB 49.91%  runtime.systemstack
    sleeping 3 seconds ...

