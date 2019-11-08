require 'socket'

# Set noop to true  for current and children scopes, if the socket on server port 22 cannot be opened.
# This function is inspired by the trlinkin-noop module (https://forge.puppet.com/trlinkin/noop)
#
Puppet::Parser::Functions.newfunction(:borgbackup_noop_connection, doc: "Set noop if we cannot connect
  to a server.
  ") do |args|

  raise(Puppet::ParseError, 'borgbackup_noop_connection(): Requires ssh server to connect to as argument ') if args.length != 1

  server = args[0]
  @noop_value = true

  begin
    TCPSocket.new(server, 22).close
    return true
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ETIMEDOUT => e
    Puppet.notice "Borgbackup: Unable to connect to ssh server (#{server}): #{e.message}"
  end

  class << self
    def lookupdefaults(type)
      values = super(type)

      # Create a new :noop parameter with the specified value (true/false) for our defaults hash
      noop = Puppet::Parser::Resource::Param.new(
        name: :noop, value: @noop_value, source: source,
      )

      # Replace whatever defaults we recieved
      values[:noop] = noop
      values
    end
  end
end
