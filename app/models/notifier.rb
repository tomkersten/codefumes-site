class Notifier < ActionMailer::Base
  default_url_options[:host] = "example.com"

  def password_reset_instructions(user)
    subject       "How to reset your password..."
    from          "Admin <noreply@#{default_url_options[:host]}>"
    recipients    user.email
    sent_on       Time.now
    body          :edit_support_password_reset_request_url => edit_support_password_reset_request_url(:id => user.perishable_token)
  end
end
