# issue_tls_block_reserve

An issue related to crypto/tls.(\*block).reserve

## Overview

The memory usage of crypto/tls.(\*block).reserve is increased linearly when https clients make a connection to a https server, then they never close its connection even if they wouldn't send/read data. But this is not a bug since the https server doesn't know whether https clients are live or not.

## Solution

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
    2017/03/21 06:59:50 called FreeOSMemory()
    2017/03/21 06:59:53 called FreeOSMemory()
    ...

This https server calls `debug.FreeOSMemory()` every 3 seconds, then outputs.

### Terminal 2

Start up https client without closing its connection. These clients sleeps 24 hours not to close the connection after requesting to the https server.

    $ cd https_client
    $ bash start_clients.sh 300 0.1
    start client to 300 every 0.1 seconds
    target server/port: localhost:44443
    client 1 is running
    client 2 is running
    client 3 is running
    ...

You can confirm multiple requests are accepted on https server when you see Terminal 1.

    2017/03/21 07:00:08 called FreeOSMemory()
    2017/03/21 07:00:08 &{GET / HTTP/1.1 1 1 map[User-Agent:[Go-http-client/1.1] Accept-Encoding:[gzip]] 0xa31750 0 [] false localhost:44443 map[] map[] <nil> map[] 127.0.0.1:34184 / 0xc820287c30 <nil>}
    2017/03/21 07:00:08 &{GET / HTTP/1.1 1 1 map[User-Agent:[Go-http-client/1.1] Accept-Encoding:[gzip]] 0xa31750 0 [] false localhost:44443 map[] map[] <nil> map[] 127.0.0.1:34186 / 0xc8202d0000 <nil>}
    ...

Stop https clients when you would confirmed.

    $ bash stop_clients.sh 
    all client_main processes are killed

### Terminal 3

After the https server/clients started, you can confirm server status to get pprof result every 3 seconds. `crypto/tls.(*block).reserve` size increases with the increasing https client connections.

    $ bash get_pprof.sh 
    target server/port: localhost:44443
    run date: 2017-03-21 07:00:10
    connection: 32
    Fetching profile from http://localhost:6060/debug/pprof/heap
    Saved profile in path/to/pprof/pprof.localhost:6060.inuse_objects.inuse_space.172.pb.gz
    363.05kB of 377.42kB total (96.19%)
    Dropped 238 nodes (cum <= 1.89kB)
    Showing top 80 nodes out of 100 (cum >= 3.12kB)
          flat  flat%   sum%        cum   cum%
         152kB 40.27% 40.27%      152kB 40.27%  crypto/elliptic.initTable
          90kB 23.85% 64.12%       90kB 23.85%  crypto/tls.(*block).reserve
       36.84kB  9.76% 73.88%    36.84kB  9.76%  net/http.newBufioReader
       36.56kB  9.69% 83.57%    36.56kB  9.69%  net/http.newBufioWriterSize
        7.50kB  1.99% 85.56%    10.86kB  2.88%  crypto/tls.(*listener).Accept
        6.06kB  1.61% 87.16%     6.06kB  1.61%  math/big.nat.make
           6kB  1.59% 88.75%        6kB  1.59%  runtime.malg
        5.06kB  1.34% 90.09%     5.06kB  1.34%  crypto/aes.(*aesCipherGCM).NewGCM
        4.11kB  1.09% 91.18%     4.15kB  1.10%  crypto/rand.(*devReader).Read
        3.09kB  0.82% 92.00%     3.09kB  0.82%  crypto/aes.NewCipher
        2.77kB  0.73% 92.73%     2.83kB  0.75%  net.parseNSSConf.func1
        2.44kB  0.65% 93.38%     2.44kB  0.65%  runtime.deferproc.func1
        1.97kB  0.52% 93.90%     2.81kB  0.75%  net/http.readRequest
        1.83kB  0.48% 94.39%   346.34kB 91.76%  net/http.(*conn).serve
        1.80kB  0.48% 94.86%        4kB  1.06%  math/big.nat.divLarge
        1.66kB  0.44% 95.30%     9.81kB  2.60%  crypto/tls.aeadAESGCM
        1.09kB  0.29% 95.59%     3.28kB  0.87%  net.(*netFD).accept
        0.47kB  0.12% 95.72%    14.73kB  3.90%  crypto/tls.(*Conn).readHandshake
        0.25kB 0.066% 95.78%     5.69kB  1.51%  crypto/rsa.SignPKCS1v15
        0.25kB 0.066% 95.85%     3.38kB  0.89%  internal/singleflight.(*Group).Do
        0.25kB 0.066% 95.91%     4.97kB  1.32%  math/big.(*Int).GCD
        0.20kB 0.054% 95.97%    12.89kB  3.42%  crypto/tls.(*serverHandshakeState).readClientHello
        0.19kB  0.05% 96.02%    16.55kB  4.39%  net/http.(*Server).ListenAndServeTLS
        0.12kB 0.033% 96.05%     4.34kB  1.15%  net/http.ListenAndServe
        0.12kB 0.033% 96.08%    16.68kB  4.42%  net/http.ListenAndServeTLS
        0.11kB 0.029% 96.11%     2.05kB  0.54%  crypto/x509.ParsePKCS1PrivateKey
        0.09kB 0.025% 96.14%   159.52kB 42.26%  crypto/tls.(*ecdheKeyAgreement).generateServerKeyExchange
        0.05kB 0.012% 96.15%     4.20kB  1.11%  crypto/tls.(*Config).serverInit
        0.03kB 0.0083% 96.16%   152.03kB 40.28%  crypto/elliptic.GenerateKey
        0.03kB 0.0083% 96.17%     4.84kB  1.28%  crypto/rsa.modInverse
        0.03kB 0.0083% 96.17%   163.50kB 43.32%  crypto/tls.(*serverHandshakeState).doFullHandshake
        0.03kB 0.0083% 96.18%     3.08kB  0.82%  crypto/tls.X509KeyPair
        0.03kB 0.0083% 96.19%     2.86kB  0.76%  net.parseNSSConf
             0     0% 96.19%    72.23kB 19.14%  bufio.(*Writer).Write
             0     0% 96.19%       72kB 19.08%  bufio.(*Writer).flush
             0     0% 96.19%     5.06kB  1.34%  crypto/cipher.NewGCM
             0     0% 96.19%     5.06kB  1.34%  crypto/cipher.NewGCMWithNonceSize
             0     0% 96.19%      152kB 40.27%  crypto/elliptic.(*p256Point).p256BaseMult
             0     0% 96.19%      152kB 40.27%  crypto/elliptic.p256Curve.ScalarBaseMult
             0     0% 96.19%     5.69kB  1.51%  crypto/rsa.(*PrivateKey).Sign
             0     0% 96.19%     5.16kB  1.37%  crypto/rsa.decrypt
             0     0% 96.19%     5.16kB  1.37%  crypto/rsa.decryptAndCheck
             0     0% 96.19%     4.20kB  1.11%  crypto/tls.(*Config).(crypto/tls.serverInit)-fm
             0     0% 96.19%   195.63kB 51.83%  crypto/tls.(*Conn).Handshake
             0     0% 96.19%       72kB 19.08%  crypto/tls.(*Conn).Write
             0     0% 96.19%    19.36kB  5.13%  crypto/tls.(*Conn).readRecord
             0     0% 96.19%   195.63kB 51.83%  crypto/tls.(*Conn).serverHandshake
             0     0% 96.19%    73.47kB 19.47%  crypto/tls.(*Conn).writeRecord
             0     0% 96.19%       10kB  2.65%  crypto/tls.(*block).readFromUntil
             0     0% 96.19%       80kB 21.20%  crypto/tls.(*block).resize
             0     0% 96.19%     7.33kB  1.94%  crypto/tls.(*halfConn).splitBlock
             0     0% 96.19%     9.81kB  2.60%  crypto/tls.(*serverHandshakeState).establishKeys
             0     0% 96.19%     5.23kB  1.39%  crypto/tls.(*serverHandshakeState).readFinished
             0     0% 96.19%     3.08kB  0.82%  crypto/tls.LoadX509KeyPair
             0     0% 96.19%     2.05kB  0.54%  crypto/tls.parsePrivateKey
             0     0% 96.19%     2.05kB  0.54%  crypto/x509.ParsePKCS8PrivateKey
             0     0% 96.19%     3.12kB  0.83%  internal/singleflight.(*Group).doCall
             0     0% 96.19%    72.23kB 19.14%  io.Copy
             0     0% 96.19%    72.23kB 19.14%  io.CopyBuffer
             0     0% 96.19%     4.15kB  1.10%  io.ReadAtLeast
             0     0% 96.19%     4.15kB  1.10%  io.ReadFull
             0     0% 96.19%    72.23kB 19.14%  io.copyBuffer
             0     0% 96.19%    72.45kB 19.20%  main.index
             0     0% 96.19%    16.71kB  4.43%  main.main
             0     0% 96.19%     4.34kB  1.15%  main.main.func1
             0     0% 96.19%        4kB  1.06%  math/big.(*Int).QuoRem
             0     0% 96.19%        4kB  1.06%  math/big.nat.div
             0     0% 96.19%     3.36kB  0.89%  net.(*TCPListener).AcceptTCP
             0     0% 96.19%     3.80kB  1.01%  net.Listen
             0     0% 96.19%     2.83kB  0.75%  net.foreachLine
             0     0% 96.19%     3.12kB  0.83%  net.glob.func16
             0     0% 96.19%     3.12kB  0.83%  net.initConfVal
             0     0% 96.19%     3.38kB  0.89%  net.internetAddrList
             0     0% 96.19%     3.12kB  0.83%  net.lookupIP
             0     0% 96.19%     3.38kB  0.89%  net.lookupIPDeadline
             0     0% 96.19%     3.38kB  0.89%  net.lookupIPMerge
             0     0% 96.19%     3.12kB  0.83%  net.lookupIPMerge.func1
             0     0% 96.19%     2.86kB  0.76%  net.parseNSSConfFile
             0     0% 96.19%     3.38kB  0.89%  net.resolveAddrList
             0     0% 96.19%     3.12kB  0.83%  net.systemConf
    sleeping 3 seconds ...

