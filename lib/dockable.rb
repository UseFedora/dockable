require "yaml"

require "aws-sdk-ssm"
require "aws-sdk-s3"

require "dockable/version"

module Dockable

  def self.load_environment_variables(bucket:, key:, ssm_prefix:)
    if presence(ssm_prefix)
      load_from_ssm(ssm_prefix: ssm_prefix)
    elsif presence(bucket) && presence(key)
      load_from_s3(bucket: bucket, key: key)
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
    elsif argv.empty?
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

  def self.load_from_ssm(ssm_prefix:)
    client     = Aws::SSM::Client.new
    ssm_prefix = "/#{ssm_prefix}" if ssm_prefix[0] != "/" # get_parameters_by_path requires leading /
    parameters = client.get_parameters_by_path(path: ssm_prefix, with_decryption: true).each.flat_map(&:parameters)
    parameters.map { |param|
      [
        param.name.split("/").last.upcase.gsub(/\W/, "_"),
        param.value.to_s
      ]
    }.to_h
  end

  def self.load_from_s3(bucket:, key:)
    client = Aws::S3::Client.new
    resp   = client.get_object(bucket: bucket, key: key)
    body   = resp.body.read
    YAML.safe_load(body).map { |k, v| [ k.to_s, v.to_s ] }.to_h
  end

end
