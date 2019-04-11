require 'simple_queue_server'
require_relative 'request_data'
require 'open3'

class MedusaCopier < SimpleQueueServer::Base

  attr_accessor :roots, :rclone_config_path

  def initialize(args = {})
    super
    self.roots = Config.roots.to_h
    self.rclone_config_path = Config.rclone_config_path
  end

  def handle_copy_request(interaction)
    request = RequestData.new(interaction)
    request.set_response_data(interaction)
    unless request.valid?
      interaction.fail_generic('Not all request parameters were provided.') and return
    end
    unless roots[request.source_root] and roots[request.target_root]
      interaction.fail_generic('Unrecognized root was provided.') and return
    end
    self.logger.info "Copying #{request.source_target}:#{request.source_key} to #{request.target_root}:#{request.target_key}"
    rclone_call_args = ['rclone', 'copyto', source_string(request), target_string(request)]
    rclone_call_args += ['--config', rclone_config_path] if rclone_config_path
    out, err, status = Open3.capture3(*rclone_call_args)
    interaction.response.set_parameter(:rclone_status, status.exitstatus)
    if status.success?
      self.logger.info "Copied #{request.source_target}:#{request.source_key} to #{request.target_root}:#{request.target_key}"
      interaction.succeed(request.to_h)
    else
      error = "Unknown copying error: #{err}"
      self.logger.error(error)
      interaction.fail_generic(error)
    end
  end

  def source_string(request)
    rclone_string(request.source_root, request.source_key)
  end

  def target_string(request)
    rclone_string(request.target_root, request.target_key)
  end

  def rclone_string(root_name, key)
    config_name = roots[root_name]['rclone_config']
    config_name + ':' + key
  end

end
