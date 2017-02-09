# issue_tls_block_reserve

An issue related to crypto/tls.(\*block).reserve

## overview

The memory usage of crypto/tls.(\*block).reserve is increased linearly when https clients make a connection to a https server, then they never close its connection even if they wouldn't send/read data. But this is not a bug since the https server doesn't kwno whether https clients are live or not.

## experience

Use Server.IdleTimeout in go 1.8.

