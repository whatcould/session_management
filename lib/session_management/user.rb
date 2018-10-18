require 'active_support/concern'

module SessionManagement::User
  extend ActiveSupport::Concern

  included do
    has_secure_password
    attr_accessor :current_password
    validate :check_current_password, on: :update
    attr_accessor :skip_current_password_check

    before_create { generate_token(:auth_token) }
  end

  class_methods do
    def authenticate(email, password)
      find_by_case_insensitive_email(email).try(:authenticate, password)
    end

    def find_by_case_insensitive_email(email)
      find_by(email: email) || where('LOWER(email) = ?', email.downcase).first
    end
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while self.class.exists?(column => self[column])
  end

  private

  def check_current_password
    if password && password_digest? && ! skip_current_password_check
      unless User.authenticate(email, current_password)
        errors.add(:current_password, "Enter your current password to change it")
        return false
      end
    end
    true
  end

end