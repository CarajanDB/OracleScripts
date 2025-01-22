Oracle Database Startup scripts

cp dbstart dbstop /usr/local/bin
chmod 755 /usr/local/bin/dbs*

cp dboracle.service /lib/systemd/system
systemctl daemon-reload
systemctl start dboracle.service
systemctl enable dboracle.service

