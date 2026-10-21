# frozen_string_literal: true

module Aardi
  module AbstractPageSupport
    include PageSupport

    def self.deprecated_by(user) = Deprecation.warn_once(self, user, 'Aardi::PageSupport')
    private_class_method :deprecated_by

    def self.extended(base) = deprecated_by(base.class)

    def self.included(base) = deprecated_by(base)
  end
end
