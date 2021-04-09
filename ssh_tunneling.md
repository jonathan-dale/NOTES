###Single hop tunelling:

```
ssh -f -N -L 9906:127.0.0.1:3306 user@dev.example.com
```

where,
  * `-f` puts ssh in background 
  * `-N` makes it not execute a remote command

This will forward all local port 9906 traffic to port 3306 on the remote dev.example.com server

###Multi-Hop Tunelling:

Tunnel from localhost to host1 and from host1 to host2:

```
ssh -L 9999:localhost:9999 host1 ssh -L 9999:localhost:1234 -N host2
```

This will open a tunnel from localhost to host1 and another tunnel from host1 to host2. However the port 9999 to host2:1234 can be used by anyone on host1. This may or may not be a problem.

Another Example:

Assume you have you have a web server running on 10.1.0.93 in a private network on port 80 which is reachable by a gateway server 198.1.1.34, here is how to open the ssh tunnel:

```
ssh -L 80:localhost:80 root@198.1.1.34 -t ssh -L 80:localhost:80 root@10.1.0.93
```

Example SSH Config:

```
Host cwg
  HostName 3.32.14.88
  Port 22
  User root
  IdentityFile ~/.ssh/id_rsa

# Access cw sync on localhost:9292
# Enable: ssh -f -N cw_tunnel
Host cw_tunnel
  HostName 198.0.218.178
  User root
  IdentityFile ~/.ssh/id_rsa
  LocalForward 9292 127.0.0.1:9292

# auto tunelling to securehost (remote host) via jumphost (gateway)
# we tell ssh that when it establishes a connection to securehost to do so using
# the stdin/stdout of the ProxyCommand as a transport. The ProxyCommand then tells
# the system to first ssh to our bastion host and open a netcat connection to host
# %h (hostname supplied to ssh) on port %p (port supplied to ssh).
Host jumphost
  ProxyCommand none
Host securehost
  ProxyCommand ssh jumphost -W %h:%p

Host bastion
  HostName 3.32.14.88
  Port 22
  User ec2-user
  IdentityFile ~/.ssh/id_rsa

Host jenkins
  HostName 10.10.1.2
  Port 22
  User ec2-user
  IdentityFile ~/.ssh/id_rsa

```
Now we can ssh into jenkins through the bastion server

```
ssh -J bastion jenkins
```


So now lets chain multiple hops in one config file
 - refernece : https://medium.com/maverislabs/proxyjump-the-ssh-option-you-probably-never-heard-of-2d7e41d43464

```
Host internal-proxy
    HostName 10.20.30.253
    Port 22
    User nopriv
    IdentityFile /home/nopriv/.ssh/id_rsa
Host external-proxy
    HostName 10.100.2.200
    Port 22
    User nopriv
    IdentityFile /home/nopriv/.ssh/id_rsa
    ProxyJump internal-proxy
Host next-hop
    HostName 10.100.2.210
    Port 22
    User nopriv
    IdentityFile /home/nopriv/.ssh/id_rsa
    ProxyJump external-proxy
Host last-hop
    HostName 10.100.2.240
    Port 22
    User nopriv
    IdentityFile /home/nopriv/.ssh/id_rsa
    ProxyJump next-hop
```

Now we can use `ssh last-hop` and what hapens is the connection is chained through `internal-proxy`, `external-proxy`, `next-hop`, then finally to `last-hop`

