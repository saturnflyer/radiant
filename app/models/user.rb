require 'digest/sha1'

class User < ActiveRecord::Base

  # Default Order
  default_scope :order => 'name'

  # Associations
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates_format_of :email, :allow_nil => true, :with => /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  validates_length_of :name, :maximum => 100, :allow_nil => true

  validates_numericality_of :id, :only_integer => true, :allow_nil => true, :message => 'must be a number'

  attr_writer :confirm_password
  class << self
    def protected_attributes
      @protected_attributes ||= [:name, :email, :locale]
    end

    def protected_attributes=(array)
      @protected_attributes = array.map{|att| att.to_sym }
    end
  end

  def has_role?(role)
    respond_to?("#{role}?") && send("#{role}?")
  end

  def after_initialize
    @confirm_password = true
  end

  def confirm_password?
    @confirm_password
  end

end
