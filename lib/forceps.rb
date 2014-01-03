require "forceps/client"
require "forceps/acts_as_copyable_model"
require "amoeba"

module Forceps
  def self.configure(options={})
    client.configure(options)
  end

  def self.client
    @@client ||= Forceps::Client.new
  end

  module Remote

  end
end

