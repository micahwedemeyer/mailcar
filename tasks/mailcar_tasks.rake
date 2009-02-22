namespace :mailcar do
  
  desc "Creates a new message. Must specify FROM, SUBJECT, and BODY_FILE."
  task :new_message => :environment do
    from = ENV['FROM'] || (raise Exception.new("Must specify FROM for email, ex: FROM='admin@mysite.org'"))
    sub = ENV['SUBJECT'] || (raise Exception.new("Must specify SUBJECT for email, ex: SUBJECT='Announcement'"))
    body_file = ENV['BODY_FILE'] || (raise Exception.new("Must specify BODY_FILE path, ex: BODY_FILE=/path/to/body_file.html"))    
    body_text = IO.read(body_file)
    
    m = MailcarMessage.create(
      :from => from,
      :subject => sub,
      :body => body_text
    )
    puts "Created message: #{m.id}"
  end
  
  desc "Prepares a message for sending by gather a list of all the email addresses to send to. Must specify MESSAGE_ID"
  task :prep_for_send => :environment do
    msg_id = ENV['MESSAGE_ID'] || (raise Exception.new("Must specify the MailcarMessage ID, ex: MESSAGE_ID=55"))
    msg = MailcarMessage.find_by_id(msg_id)
    
    raise Exception.new("No MailcarMessage found with id: #{msg_id}") unless msg
    
    # TODO: Find a way to make this a little more reusable
    emails = extract_emails
    
    emails.each do |em|
      MailcarSending.create(
        :mailcar_message => msg,
        :email_address => em,
        :sent_at => nil
      )
    end
    
    puts "Message prepared.  Will be sent to #{emails.size} recipients."
  end
  
  desc "Sends (or continues an aborted send) a message. Must specify MESSAGE_ID"
  task :send => :environment do
    msg_id = ENV['MESSAGE_ID'] || (raise Exception.new("Must specify the MailcarMessage ID, ex: MESSAGE_ID=55"))
    msg = MailcarMessage.find_by_id(msg_id)
    
    raise Exception.new("No MailcarMessage found with id: #{msg_id}") unless msg
    
    # The time between each send.  We put a small buffer so we don't look like a spammer, hopefully
    # TODO: Make this configurable
    sleep_time_in_s = 3
    
    unsent = msg.unsent
    count = 0
    total = unsent.size
    puts "There are #{total} recipients remaining."
    unsent.each do |sending|
      begin
        # TODO: Make it configurable somehow as to what template is used for sending
        Mailing::deliver_newsletter(
          sending.email_address,
          sending.mailcar_message.from,
          sending.mailcar_message.subject,
          sending.mailcar_message.body
        )
      rescue Exception => e
        puts("Error while sending to #{sending.email_address}")
        puts(e.to_s)
      end
      
      sending.update_attribute(:sent_at, Time.now)
      
      count += 1
      sleep(sleep_time_in_s)
      
      if count % 25 == 0
        hours_remaining = (sleep_time_in_s * (total - count)) / 3600.0
        puts("Sent #{count}/#{total} -- Estimated remaining time: #{sprintf("%.2f", hours_remaining)} hours")
      end
    end
  end
  
  def extract_emails
    users = User.find_all_by_wants_newsletter(1)
    users.collect {|u| u.email}
  end

end
