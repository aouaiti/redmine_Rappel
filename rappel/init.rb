require 'redmine'
require File.expand_path('../lib/rappel_patches', __FILE__)

Rails.logger.info "Initializing Rappel plugin"

Redmine::Plugin.register :rappel do
  name 'Rappel Plugin'
  author 'Aouaiti Ahmed'
  description 'A plugin for sending periodic reminders about tasks until they are completed'
  version '0.1'
  
  # Register as a project module
  project_module :rappel do
    permission :view_rappels, { rappels: [:index] }
    permission :manage_rappels, { rappels: [:index, :new, :create, :edit, :update, :destroy] }
  end
  
  # Add menu item
  menu :project_menu, 
       :rappels, 
       { controller: 'rappels', action: 'index' },
       caption: 'Rappels', 
       param: :project_id
end

# Load our extensions to set up automatic scheduling
Rails.configuration.to_prepare do
  # Ensure the necessary files are loaded
  begin
    require_dependency 'rappel_scheduler'
    
    # Schedule the job if ActiveJob is available and we're in server mode
    if defined?(ActiveJob) && defined?(Rails::Server)
      # Use a small delay to make sure all components are loaded
      if Rails.env.production?
        Rails.logger.info "Rappel: Will schedule job when Rails is fully loaded"
        Rails.application.config.after_initialize do
          # Load the job class
          require_dependency File.expand_path('../app/jobs/process_rappels_job', __FILE__)
          # Schedule the initial job
          ProcessRappelsJob.schedule
          Rails.logger.info "Rappel: Initial job scheduled"
        end
      end
    end
  rescue => e
    Rails.logger.error "Rappel: Error setting up automatic scheduler: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end 