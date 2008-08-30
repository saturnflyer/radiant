module Radiant
  class ExtensionMigrator < ActiveRecord::Migrator
  
    def self.migrate_extensions
      Extension.descendants.each do |ext|
        ext.migrator.migrate
      end
    end
  
    def initialize(extension)
      @extension = extension
      @migrations_path = @extension.root + '/db/migrate'
    end
  
    def migrate_with_extension_support(how = :up)
      raise StandardError.new("This database does not yet support migrations") unless ActiveRecord::Base.connection.supports_migrations?
    
      if [:up, :down].include?(how)
        @direction = how
        @target_version = nil
      else
        @target_version = how
        case
          when @target_version.nil?, current_version < @target_version
            @direction = :up
          when current_version > @target_version
            @direction = :down
          when current_version == @target_version
            return # You're on the right version
        end
      end
      migrate_without_extension_support
    end
    alias_method_chain :migrate, :extension_support
    
    def current_version
      @extension.meta.schema_version
    end
    
    def migrated
      ActiveRecord::Base.connection.select_values("SELECT version FROM extension_migrations WHERE extension_id = #{@extension.meta.id}").map(&:to_i).sort
    end
  
    def record_version_state_after_migrating(version)
      if down?
        ActiveRecord::Base.connection.update("DELETE FROM extension_migrations WHERE version = '#{version}' AND extension_id = #{@extension.meta.id}")
      else
        ActiveRecord::Base.connection.insert("INSERT INTO extension_migrations (version, extension_id) VALUES ('#{version}', #{@extension.meta.id})")
      end
    end
  
  end

end