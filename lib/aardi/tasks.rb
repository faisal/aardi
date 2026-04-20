# frozen_string_literal: true

require 'aardi'

Dir[File.join(__dir__, 'tasks', '*.rake')].each { |f| load f }
