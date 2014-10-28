# coding: utf-8
# vim: tabstop=2 noexpandtab

require 'puppet'
require 'yaml'

# require any other Ruby libraries necessary for this specific report

Puppet::Reports.register_report(:zabbix_report) do
	desc "Process reports via the Zabbix API."

	def process
      configurationfile = "/etc/puppet/zabbix_report.yaml"
      if Puppet::FileSystem.exist?(configurationfile)
				configuration = YAML.load_file('/etc/puppet/zabbix_report.yaml')
			else
        Puppet.notice "Cannot send zabbix report; no configuration file found at /etc/puppet/zabbix_report.conf"
        return
      end

			default_sender_path = configuration['sender_path']
			default_server      = configuration['server']
			default_port        = configuration['port']
			default_item        = configuration['item']

			send = false

			configuration['hostlist'].each do |key, value|
				if m = self.host.match(key)
					if value['taglist'].include?('all')
						send = true
					else
						messages = nil
						messages = self.logs.find_all do |log|
							value['taglist'].detect { |tag| log.tagged?(tag) }

						if messages.nil? || messages.empty?
							send = true
						end
					end
				end
				if send
					sender_path = value['sender_path'] ? value['sender_path'] : default_sender_path
					server      = value['server'] ? value['server'] : default_server
					port        = value['port'] ? value['port'] : default_port
					item        = value['item'] ? value['item'] : default_item
				 	zabbix_command = "#{sender_path} --zabbix-server #{server}"\
				                   " --port #{port} --host #{self.host} --key #{item} --value #{self.status}"
					system(zabbix_command)
				end
			end
		end
	end
end
