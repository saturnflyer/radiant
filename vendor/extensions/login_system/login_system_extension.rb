require_dependency 'application_controller'

class LoginSystemExtension < Radiant::Extension
  version "1.0"
  description "Default login system for Radiant"
  url "http://github.com/radiant/radiant/tree/master/vendor/extensions/login_system"
  
  def activate
    ApplicationController.class_eval { include LoginSystem }
    User.protected_attributes += [:login, :password, :password_confirmation]
    User.class_eval {      
      validates_uniqueness_of :login

      validates_confirmation_of :password, :if => :confirm_password?

      validates_presence_of :name, :login, :message => 'required'
      validates_presence_of :password, :password_confirmation, :if => :new_record?

      validates_length_of :login, :within => 3..40, :allow_nil => true
      validates_length_of :password, :within => 5..40, :allow_nil => true, :if => :validate_length_of_password?
      validates_length_of :email, :maximum => 255, :allow_nil => true

      def sha1(phrase)
        Digest::SHA1.hexdigest("--#{salt}--#{phrase}--")
      end

      def self.authenticate(login, password)
        user = find_by_login(login)
        user if user && user.authenticated?(password)
      end

      def authenticated?(password)
        self.password == sha1(password)
      end

      def remember_me
        update_attribute(:session_token, sha1(Time.now + Radiant::Config['session_timeout'].to_i)) unless self.session_token?
      end

      def forget_me
        update_attribute(:session_token, nil)
      end

      private

        def validate_length_of_password?
          new_record? or not password.to_s.empty?
        end

        before_create :encrypt_password
        def encrypt_password
          self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{login}--sweet harmonious biscuits--")
          self.password = sha1(password)
        end

        before_update :encrypt_password_unless_empty_or_unchanged
        def encrypt_password_unless_empty_or_unchanged
          user = self.class.find(self.id)
          case password
          when ''
            self.password = user.password
          when user.password
          else
            encrypt_password
          end
        end
    }
  end
end
