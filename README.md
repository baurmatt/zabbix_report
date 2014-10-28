zabbix_report
=============

A Puppet report processor that announces changes to Zabbix

Configuration file
------------------

The configuration file needs to be places at /etc/puppet/zabbix_report.yaml

``` yaml
server: zabbix
port: 10051
sender_path: /usr/local/bin/zabbix_sender
item: Puppet.Run
hostlist:
   example-l01-.*:
      taglist:
         - apache2
      server: zabbixtest
      port: 1337
      sender_path: /path/to/sender
      item: Magic.Zabbix.Item
```

The report processor will check if any item from hostlist regex matches the host given to the processor. If it matches, the processor will check whether any of the given tags in taglist matches the host, if so it will send the notification to Zabbix. If you want all changes send to Zabbix, just set taglist to 'all'.

The default values for the server, port, sender_path and item configuration parameter can be override within each host matching.
