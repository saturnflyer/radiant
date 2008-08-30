class CreateExtensionMigrationsTable < ActiveRecord::Migration
  def self.up
    create_table :extension_migrations do |t|
      t.column :extension_id, :integer
      t.column :version, :string
    end
    add_index :extension_migrations, :extension_id
    remove_column :extension_meta, :schema_version
  end

  def self.down
    add_column :extension_meta, :schema_version, :string, :limit => 11, :default => 0
    drop_table :extension_migrations
  end
end
