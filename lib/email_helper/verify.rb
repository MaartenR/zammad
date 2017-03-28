module EmailHelper
  class Verify

=begin

get result of inbound probe

  result = EmailHelper::Verify.email(
    inbound: {
      adapter: 'imap',
      options: {
        host: 'imap.gmail.com',
        port: 993,
        ssl: true,
        user: 'some@example.com',
        password: 'password',
      },
    },
    outbound: {
      adapter: 'smtp',
      options: {
        host: 'smtp.gmail.com',
        port: 25,
        ssl: true,
        user: 'some@example.com',
        password: 'password',
      },
    },
    sender: 'sender_and_recipient_of_verify_email@example.com',
  )

returns on success

  {
    result: 'ok'
  }

returns on fail

  {
    result: 'invalid',
    message: 'Verification Email not found in mailbox.',
    subject: subject,
  }

or

  {
    result: 'invalid',
    message: 'Authentication failed!.',
    subject: subject,
  }

=end

    def self.email(params)

      # send verify email
      subject = if !params[:subject] || params[:subject].empty?
                  '#' + rand(99_999_999_999).to_s
                else
                  params[:subject]
                end
      result = EmailHelper::Probe.outbound(params[:outbound], params[:sender], subject)
      if result[:result] != 'ok'
        result[:source] = 'outbound'
        return result
      end
      
      # validate adapter
      adapter = params[:inbound][:adapter].downcase
      if !EmailHelper.available_driver[:inbound][adapter.to_sym]
        return {
          result: 'failed',
          message: "Unknown adapter '#{adapter}'",
        }
      end

      # looking for verify email
      9.times {
        sleep 5

        # fetch mailbox
        fetch_result = nil

        begin
          require "channel/driver/#{adapter.to_filename}"

          Rails.logger.debug "verifying inbound driver #{adapter.to_classname}"
          driver_class    = Object.const_get("Channel::Driver::#{adapter.to_classname}")
          driver_instance = driver_class.new
          if driver_instance.fetchable?(nil)
            fetch_result    = driver_instance.fetch(params[:inbound][:options], self, 'verify', subject)
          else
            fetch_result = {
              result: 'ok',
              source: 'inbound',
              subject: subject,
            }
          end
        rescue => e
          result = {
            result: 'invalid',
            source: 'inbound',
            message: e.to_s,
            message_human: EmailHelper::Probe.translation(e.message),
            invalid_field: EmailHelper::Probe.invalid_field(e.message),
            subject: subject,
          }
          return result
        end

        next if !fetch_result
        next if fetch_result[:result] != 'ok'

        return fetch_result
      }

      {
        result: 'invalid',
        message: 'Verification Email not found in mailbox.',
        subject: subject,
      }
    end

  end

end
