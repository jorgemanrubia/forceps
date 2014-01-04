require "forceps/client"
require "forceps/acts_as_copyable_model"
require 'logging'

module Forceps
  def self.configure(options={})
    client.configure(options)
  end

  def self.client
    @@client ||= Forceps::Client.new
  end

  def self.logger
    @@logger ||= begin
      logger = Logging.logger(STDOUT)
      logger.level = :debug
      logger
    end
  end

  def self.logger=(logger)
    @@logger = logger
  end

  module Remote

  end
end

