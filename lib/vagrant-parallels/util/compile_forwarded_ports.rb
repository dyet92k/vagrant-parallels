require 'vagrant/util/scoped_hash_override'

module VagrantPlugins
  module Parallels
    module Util
      module CompileForwardedPorts
        include Vagrant::Util::ScopedHashOverride

        # This method compiles the forwarded ports into {ForwardedPort}
        # models.
        def compile_forwarded_ports(config)
          mappings = {}

          config.vm.networks.each do |type, options|
            if type == :forwarded_port
              guest_port = options[:guest]
              host_port  = options[:host]
              protocol   = options[:protocol] || 'tcp'
              options    = scoped_hash_override(options, :parallels)
              id         = options[:id]

              # If the forwarded port was marked as disabled, ignore.
              next if options[:disabled]

              # Temporary disable automatically pre-configured forwarded ports
              # for SSH, since it is working not so well [GH-146]
              next if id == 'ssh'

              mappings[host_port.to_s + protocol.to_s] =
                Model::ForwardedPort.new(id, host_port, guest_port, options)
            end
          end

          mappings.values
        end
      end
    end
  end
end
