require 'net/http'
require 'json'
module Nextia
  module Implementations
    module Mailgun
     class MailgunFacade
        def initialize(api_key, domain)
          @api_key = api_key
          @domain = domain
        end

        def send(from, to, subject, template)
          @request_body = {
                "from" => from,
                "to" => to,
                "subject" => subject,
                "template" => template
          }
          begin
            email_between_from = from.split("<").last.split(">").first
            Nextia::Implementations::Mailgun::Errors.validates_email(email_between_from)
            Nextia::Implementations::Mailgun::Errors.validates_email(to)
          rescue Nextia::Implementations::Mailgun::Errors::InvalidEmailException => e
            puts e.message
          end
          request = Net::HTTP.post_form(endpoint_uri, @request_body)
          return request
        end

        def endpoint_uri
          URI("https://api:#{@api_key}@api.mailgun.net/v3/#{@domain}/messages")
        end
      end

      module Errors
        def self.validates_email(email)
          raise InvalidEmailException if (email =~ URI::MailTo::EMAIL_REGEXP).nil?
        end
        class InvalidEmailException < StandardError
          def message
            "Email is not valid"
          end 
        end
      end

    end
  end
end