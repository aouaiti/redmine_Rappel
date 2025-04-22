class ProcessRappelsJob < ApplicationJob
  queue_as :default
  
  # This job will be scheduled to run periodically
  def perform
    # Using a file-based lock to prevent multiple processes from sending emails
    lock_file = File.join(Rails.root, 'tmp', 'rappel_processing.lock')
    
    # Skip if another process is already running
    if File.exist?(lock_file)
      # Check if the lock is stale (older than 10 minutes)
      if (Time.now - File.mtime(lock_file)) < 10.minutes
        Rails.logger.info "ProcessRappelsJob skipping at #{Time.now} - another process is running"
        # Re-schedule this job to run again in 1 minute
        self.class.set(wait: 1.minute).perform_later
        return
      else
        # Lock is stale, we can delete it
        Rails.logger.warn "Removing stale lock file from #{File.mtime(lock_file)}"
        File.delete(lock_file)
      end
    end
    
    begin
      # Create lock file
      FileUtils.touch(lock_file)
      
      Rails.logger.info "ProcessRappelsJob starting at #{Time.now} with lock"
      RappelScheduler.process_due_rappels
      
    ensure
      # Always release the lock when done
      File.delete(lock_file) if File.exist?(lock_file)
    end
    
    # Re-schedule this job to run again in 1 minute
    self.class.set(wait: 1.minute).perform_later
    Rails.logger.info "ProcessRappelsJob scheduled to run again in 1 minute"
  end
  
  # This method will be called when the server starts
  def self.schedule
    Rails.logger.info "Initial scheduling of ProcessRappelsJob at #{Time.now}"
    ProcessRappelsJob.set(wait: 1.minute).perform_later
  end
end 