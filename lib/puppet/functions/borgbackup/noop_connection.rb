require 'socket'

#
# @summary
#   Set noop to true  for current and children scopes, if the socket on server port 22 cannot be opened.
#
# Remark: This function is inspired by the trlinkin-noop module (https://forge.puppet.com/trlinkin/noop)
#
Puppet::Functions.create_function(:'borgbackup::noop_connection', Puppet::Functions::InternalFunction) do
  # @param bb_server the server to check
  # @return [Boolean] true on success

  dispatch :noop_connection do
    scope_param
    param 'String[1]', :bb_server
  end

  def noop_connection(scope, bb_server)
    @noop_value = true
    begin
      TCPSocket.new(bb_server, 22).close
      def scope.noop_value
        false
      end
      return true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ETIMEDOUT => e
      Puppet.notice "Borgbackup: Unable to connect to ssh server (#{bb_server}): #{e.message}"
    end
    def scope.noop_value
      true
    end

    def scope.lookupdefaults(type)
      values = super(type)

      # Create a new :noop parameter with the specified value (true/false) for our defaults hash
      noop = Puppet::Parser::Resource::Param.new(
        name: :noop,
        value: noop_value,
        source: source,
      )

      # Adding this default fixes a corner case with resource collectors
      @defaults[type][:noop] = noop

      # Replace whatever defaults we recieved
      values[:noop] = noop
      values
    end
  end
end
