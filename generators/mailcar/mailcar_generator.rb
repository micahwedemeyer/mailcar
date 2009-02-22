# Shamelessly derived from a shameless derivation of Rick Olsen's acts_as_attachment
class MailcarGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
#      m.directory File.join('test/unit', class_path)
#      m.directory File.join('test/fixtures', class_path)

      # Model class, unit test, and fixtures.
      m.template 'mailcar_message.rb',      File.join('app/models', class_path, "mailcar_message.rb")
      m.template 'mailcar_sending.rb',      File.join('app/models', class_path, "mailcar_sending.rb")
 #     m.template 'model.rb',  File.join('app/models', class_path, "#{file_name}.rb")
 #     m.template 'unit_test.rb',  File.join('test/unit', class_path, "#{file_name}_test.rb")
 #     m.template 'fixtures.yml',  File.join('test/fixtures', class_path, "#{table_name}.yml")
 
      
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "create_mailcar_tables"
      end
    end
  end

  protected
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    end
end
