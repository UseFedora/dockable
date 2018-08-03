require "dockable/version"

require "yaml"

module Dockable

  def self.load_environment_variables(bucket:, key:, ssm_prefix:)
    if presence(ssm_prefix)
      require "aws-sdk-ssm"
      client     = Aws::SSM::Client.new
      ssm_prefix = "/#{ssm_prefix}" if ssm_prefix[0] != "/" # get_parameters_by_path requires leading /
      parameters = client.get_parameters_by_path(path: ssm_prefix).parameters
      if parameters.count != 0
        parameters.map{|param| [param.split("/").last.upcase, param.value]}.to_h
      else
        {}
      end
    elsif presence(bucket) && presence(key)
      require "aws-sdk-s3"
      client = Aws::S3::Client.new
      resp   = client.get_object(bucket: bucket, key: key)
      body   = resp.body.read
      YAML.load(body).map { |k, v| [ k.to_s, v.to_s ] }.to_h
    else
      STDERR.puts "Dockable warning: No bucket/key or SSM Prefix found, no environment file loaded."
      {}
    end
  end

  def self.load_command(argv, procfile_location: nil)
    procfile_location = presence(procfile_location) || "Procfile"
    if File.exist?(procfile_location) && argv.size == 1
      commands = YAML.load_file(procfile_location)
      if commands.has_key?(argv[0])
        [ commands[argv[0]].to_s ]
      else
        argv
      end
    elsif argv.size == 0
      fail ArgumentError, "No command specified"
    else
      argv
    end
  end

  def self.presence(value)
    case value
    when nil, false then nil
    when /\A[[:space:]]*\z/
      nil
    when Array, Hash
      if value.empty?
        nil
      else
        value
      end
    else
      value
    end
  end

end
