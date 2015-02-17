require 'fileutils'
require 'systemu'
require 'net/ssh'
require 'net/scp'
require 'rspec-system/node_set/vagrant_base'

module RSpecSystem
  # A NodeSet implementation for Vagrant.
  class NodeSet::VagrantVirtualbox < NodeSet::VagrantBase
    PROVIDER_TYPE = 'vagrant_virtualbox'

    # Name of provider
    #
    # @return [String] name of the provider as used by `vagrant --provider`
    def vagrant_provider_name
      'virtualbox'
    end

    # Adds virtualbox customization to the Vagrantfile
    #
    # @api private
    # @param name [String] name of the node
    # @param options [Hash] customization options
    # @return [String] a series of vbox.customize lines
    def customize_provider(name,options)
      custom_config = ""
      options.each_pair do |key,value|
        next if global_vagrant_options.include?(key)
        case key
        when 'cpus','memory'
          custom_config << "    prov.customize ['modifyvm', :id, '--#{key}','#{value}']\n"
        when 'mac'
          custom_config << "    prov.customize ['modifyvm', :id, '--macaddress1','#{value}']\n"
        when 'disk'
          file_to_disk = ENV['HOME'] + "/sparedisk#{name}"
          value = value * 1024
          custom_config << " prov.customize ['createhd', '--filename', '#{file_to_disk}', '--size', #{value}]\n"
          custom_config << " prov.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', '#{file_to_disk}.vdi']\n"
        when 'idedisk'
          file_to_disk = ENV['HOME'] + "/sparedisk#{name}"
          value = value * 1024
          custom_config << " prov.customize ['createhd', '--filename', '#{file_to_disk}', '--size', #{value}]\n"
          custom_config << " prov.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', '#{file_to_disk}.vdi']\n"
        else
          log.warn("Skipped invalid custom option for node #{name}: #{key}=#{value}")
        end
      end
      custom_config
    end
  end
end
