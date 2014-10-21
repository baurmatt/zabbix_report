# coding: utf-8
# vim: tabstop=2 noexpandtab

require 'puppet'
# require any other Ruby libraries necessary for this specific report

Puppet::Reports.register_report(:zabbix_report) do
	desc "Process reports via the Zabbix API."

	def process
      configurationfile = "/etc/puppet/zabbix_report.conf"
      unless Puppet::FileSystem.exist?(configurationfile)
        Puppet.notice "Cannot send zabbix report; no configuration file found at /etc/puppet/zabbix_report.conf"
        return
      end

      configuration = ZabbixReportConfiguration.new(File.read(configurationfile))
      zabbix_command = "#{configuration.sender_path} --zabbix-server #{configuration.server}"\
                       " --port #{configuration.port} --host #{configuration.host} --key #{configuration.item}"

      if configuration.type == "status"
         zabbix_command = "#{zabbix_command} --value #{self.status}"
      elsif configuration.type == "log"
         file = File.new("/tmp/zabbix_report_test" + rand(999999999).to_s, "w")
         file.puts(self.logs)
         file.close
      else
         Puppet.fail "Unknow configuration parameter value for type found: #{type}"
      end
   end
end

class ZabbixReportConfiguration
   attr_accessor :type, :server, :port, :sender_path, :item, :host

   def initialize(text = nil)
      self.type = "status"
      self.server = "127.0.0.1"
      self.port = "10051"
      self.sender_path = "/usr/local/bin/zabbix_sender"
      self.item = "Puppet.Run"
      if text
         self.parse(text)
      end
   end

   def parse(text)
      text.split("\n").each do |line|
         case line.chomp
         when /^\s*#/; next
         when /^\s*$/; next
         when /^\s*(.+)\s*=\s*(.+)\s*$/
            case $1
            when "type"
               self.type = $2
            when "server"
               self.server = $2
            when "port"
               self.port = $2
            when "sender_path"
               self.sender_path = $2
            when "item"
               self.item = $2
            else
               raise ArgumentError, "Found invalid configuration parameter #{2} in zabbix_report configuration file"
            end
         end
      end
   end
end
