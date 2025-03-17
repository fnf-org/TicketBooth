# frozen_string_literal: true

# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# @description Enable parameter wrapping for JSON. You can disable this by
#              setting :format to an empty array.
#
# @see https://edgeapi.rubyonrails.org/classes/ActionController/ParamsWrapper.html
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

PARAMS_WRAPPER_MUTEX = Mutex.new

# Since Rails 8 options class is missing synchronize method for some reason
ActionController::ParamsWrapper::Options.class_eval do
  def synchronize(&)
    PARAMS_WRAPPER_MUTEX.synchronize(&)
  end
end
