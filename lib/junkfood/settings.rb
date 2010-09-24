# encoding: utf-8
# Copyright 2010 Benjamin Yu <http://benjaminyu.org/>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'active_support/core_ext/hash'
require 'singleton'
require 'yaml'

module Junkfood

  ##
  # A Global Settings Singleton class for Rails applications.
  #
  class Settings
    include Singleton

    attr_reader :config

    ##
    # Reads the settings.yml and settings_<env>.yml file for configuration
    # options and merges them together. The env is the Rails.env,
    # and the settings files are assumed to be in the Rails.root's config
    # subdirectory.
    #
    def initialize
      file = "#{Rails.root}/config/settings.yml"
      env_file = "#{Rails.root}/config/settings_#{Rails.env}.yml"
      @config = {}
      if File.exist? file
        base_cfg = YAML.load File.read(file)
        @config.deep_merge! base_cfg if base_cfg.kind_of? Hash
      end
      if File.exist? env_file
        env_cfg = YAML.load File.read(env_file)
        @config.deep_merge! env_cfg if env_cfg.kind_of? Hash
      end
    end

    ##
    # @return (Hash) the singleton's configuration.
    #
    def self.config
      instance.config
    end

    ##
    # Looks up the configuration option.
    #
    # @param key (Object) the configuration option key.
    # @return (Object) the configuration value.
    #
    def self.[](key)
      config[key]
    end
  end
end
