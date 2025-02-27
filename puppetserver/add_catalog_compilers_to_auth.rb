#!/opt/puppetlabs/puppet/bin/ruby

require 'hocon/parser/config_document_factory'
require 'hocon/config_value_factory'
require 'optparse'

auth_conf = '/etc/puppetlabs/puppetserver/conf.d/auth.conf'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.on("-h", "--hostnames HOSTNAMES", "Comma-separated list of hostnames to allow") do |h|
    options[:hostnames] = h.split(',')
  end
end.parse!

if options[:hostnames].nil? || options[:hostnames].empty?
  puts "Error: Hostnames must be provided using -h or --hostnames"
  exit 1
end

conf_hash = Hocon.load(auth_conf)
conf = Hocon::Parser::ConfigDocumentFactory.parse_file(auth_conf)

new_allow_list = options[:hostnames]

new_rule = {
  'allow' => new_allow_list,
  'match-request' => {
      'method' => [
          'get',
          'post'
      ],
      'path' => '^/puppet/v3/catalog/([^/]+)$',
      'type' => 'regex'
  },
  'name' => 'puppetlabs v3 catalog from agents',
  'sort-order' => 500
}

# Find the index of the rule to replace (if it exists)
rule_index = conf_hash['authorization']['rules'].find_index do |rule|
  rule['name'] == "puppetlabs v3 catalog from agents"
end

if rule_index
  #puts "Replacing existing auth rule"
  conf_hash['authorization']['rules'][rule_index] = new_rule
end

new_conf = conf.set_config_value('authorization.rules', Hocon::ConfigValueFactory.from_any_ref(conf_hash['authorization']['rules']))

File.open(auth_conf, 'w') { |file| file.write(new_conf.render) }

puts "Successfully updated #{auth_conf}"