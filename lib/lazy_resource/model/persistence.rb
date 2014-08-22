module LazyResource
  module Persistence
    extend ActiveSupport::Concern

    def save
      return true if !changed?
      return false if !valid?
      run_callbacks :save do
        new_record? ? create : update
      end
    end

    def create
      run_callbacks :create do
        Request.new(self).body(to_body_for_create).method(:post).run.success?
      end
    end

    def update
      run_callbacks :update do
        Request.new(self).body(to_body_for_update).method(:put).run.success?
      end
    end

    def new_record?
      !self.persisted?
    end

    def persisted?
      @persisted
    end

    def to_body
      self.as_json(only_changed: true).to_json
    end

    alias :to_body_for_update :to_body
    alias :to_body_for_create :to_body

    included do |base|
      base.include(ActiveSupport::Dirty)
      base.include(ActiveModel::Validations)
    end
  end
end
