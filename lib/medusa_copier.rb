require 'simple_queue_server'

class MedusaCopier < SimpleQueueServer::Base

  attr_accessor :root


  def initialize(args = {})
    super
  end

  def handle_copy_request(interaction)

  end

end
