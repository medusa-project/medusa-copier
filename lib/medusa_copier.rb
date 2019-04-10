require 'simple_queue_server'
require_relative 'request_data'
require 'open3'

class MedusaCopier < SimpleQueueServer::Base

  attr_accessor :roots

  def initialize(args = {})
    super
    self.roots = Config.roots.to_h
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
    out, err, status = Open3.capture3('rclone', 'copyto', source_string(request), target_string(request))
    interaction.response.set_parameter(:rclone_status, status.exitstatus)
    if status.success?
      interaction.succeed(request.to_h)
      self.logger.info "Copied #{request.source_target}:#{request.source_key} to #{request.target_root}:#{request.target_key}"
    else
      interaction.fail_generic("Unknown copying error: #{err}")
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
