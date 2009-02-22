class MailcarMessage < ActiveRecord::Base
  has_many :mailcar_sendings
  
  def unsent
    self.mailcar_sendings.find_by_sent_at(nil)
  end
  
end