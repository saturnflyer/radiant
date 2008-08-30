class Radiant::ExtensionMeta < ActiveRecord::Base
  set_table_name "extension_meta"
  validates_presence_of :name
  validates_uniqueness_of :name

  def schema_version
    version = ActiveRecord::Base.connection.select_values(
      "SELECT version FROM extension_migrations WHERE extension_id = #{id}"
    ).map(&:to_i).max rescue nil
    version || 0
  end
end