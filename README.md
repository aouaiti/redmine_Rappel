# Redmine Rappel Plugin

A Redmine plugin that sends periodic reminder emails for open tasks until they are completed.

## Features

- Send recurring reminder emails for specific issues
- Customizable email frequency (minutes, hours, days, weeks, months)
- Automatic detection of closed/resolved issues
- Email notifications to assignee, author, and watchers
- Customizable email subject and message

## Compatibility

- Redmine 4.0.x, 4.1.x, 4.2.x, 5.x, 6.x
- Ruby 2.5+
- Database: Any supported by Redmine

## Installation

1. Clone the repository to your Redmine plugins directory:
   ```
   cd {REDMINE_ROOT}/plugins
   git clone https://github.com/yourusername/redmine_rappel.git rappel
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Run migrations:
   ```
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
   ```

4. Restart Redmine

## Configuration

1. **Enable the plugin for your project**
   - Go to Project settings → Modules
   - Check "Rappel" to enable the plugin

2. **Choose your scheduling method**
   - **Option 1: ActiveJob** (runs automatically every minute)
     - No additional setup required
     - Works out of the box when Redmine is running
   
   - **Option 2: Cron job** (recommended for production)
     ```
     # Add to crontab (runs every 5 minutes)
     */5 * * * * cd /path/to/redmine && RAILS_ENV=production bundle exec rake rappel:send_rappels
     ```

## Usage

1. **Creating reminders**
   - Navigate to your project
   - Click "Rappels" in the project menu
   - Click "New Rappel"
   - Fill in the details:
     - Subject: The email subject (you can use {{issue}} for the issue subject, {{id}} for issue ID)
     - Message: Optional message to include in the email
     - Issue: Select the issue to send reminders for
     - Frequency: Set how often to send the reminder

2. **Managing reminders**
   - View, edit or delete existing reminders through the Rappels section

## Troubleshooting

- Check Redmine logs for any error messages
- Ensure you're using only one scheduling method (either cron or ActiveJob, not both)

## Uninstallation

1. Remove the plugin migrations:
   ```
   bundle exec rake redmine:plugins:migrate NAME=rappel VERSION=0 RAILS_ENV=production
   ```

2. Remove the plugin directory:
   ```
   rm -rf plugins/rappel
   ```

3. Restart Redmine

## License

This plugin is licensed under the MIT license.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request 
