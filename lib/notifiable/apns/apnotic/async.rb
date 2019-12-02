require 'notifiable'
require 'apnotic'
require 'grocer'

module Notifiable
  module Apns
    module Apnotic
  		class Async < Notifiable::NotifierBase
        
        notifier_attribute :certificate, :bundle_id, :passphrase, :sandbox
        
        attr_reader :certificate, :passphrase, :bundle_id
        
        def sandbox?
          @sandbox == "1"
        end
      
  			protected      
  			def enqueue(device, notification)        				
          raise "certificate missing" if certificate.nil?
          raise "bundle_id missing" if bundle_id.nil?

          apnotic_notification = build_notification(device, notification)
          apnotic_enqueue(apnotic_notification, device)
          
        rescue SocketError, Errno::ECONNRESET => e
          # retry on socket error, see https://github.com/ostinelli/apnotic/issues/41#issue-203624698
          apnotic_enqueue(apnotic_notification, device)
  			end
    

        private 
        def apnotic_enqueue(apnotic_notification, device)
          push = connection.prepare_push(apnotic_notification)
          push.on(:response) {|response| process_response(response, device) }
          connection.push_async(push)
        end
        
        def url
          self.sandbox? ? ::Apnotic::APPLE_DEVELOPMENT_SERVER_URL : ::Apnotic::APPLE_PRODUCTION_SERVER_URL
        end
        
        def process_response(response, device)
          if response.ok?
            processed(device)
          else
            processed(device, response.status, response.body['reason'])
            device.destroy if response.status == '410' || (response.status == '400' && ['BadDeviceToken', 'DeviceTokenNotForTopic'].include?(response.body['reason']))
          end
        end
        
        def close_connection
          connection.join
          connection.close
          @connection = nil          
        end
        
        def flush
          close_connection
          process_feedback
        end
        
        def connection
          @connection ||= ::Apnotic::Connection.new(cert_path: StringIO.new(certificate), cert_pass: passphrase, url: url)
        end
                  
        def build_notification(device, notification)
          payload = ::Apnotic::Notification.new(device.token)
          payload.alert = {}
          payload.alert[:title] = notification.title if notification.title
          payload.alert[:body] = notification.message if notification.message
          payload.category = notification.category if notification.category
          payload.content_available = notification.content_available if notification.content_available
          payload.priority = 5  if notification.content_available # infer valid priority if content_avalible flag is true
          payload.sound = notification.sound || notification.content_available ? nil : 'default'
          payload.badge = notification.badge_count if notification.badge_count          
          payload.custom_payload = notification.send_params
          payload.thread_id = notification.thread_id if notification.thread_id
          payload.mutable_content = (notification.mutable_content if notification.mutable_content) || notification.app.save_notification_statuses
          payload.category = notification.category if notification.category
          payload.topic = bundle_id
          payload.expiration = 0 || notification.expiry.to_f
          payload.identifier = notification.identifier if notification.identifier
          
          payload
        end
        
        def grocer_feedback
  				@grocer_feedback ||= ::Grocer.feedback(feedback_config)
        end
        
        def feedback_host
          self.sandbox? ? "feedback.sandbox.push.apple.com" : "feedback.push.apple.com"
        end
        
        def feedback_config
          {
            certificate: certificate,
            passphrase:  passphrase,
            gateway:     feedback_host,
            port:        2196,
            retries:     3
          }
        end
    
        def process_feedback
  				grocer_feedback.each do |attempt|
  					token = attempt.device_token
  					device_token = DeviceToken.find_by_token(token)
  					if device_token
  						device_token.destroy if device_token.updated_at < attempt.timestamp
  						logger.info("Device #{token} removed at #{attempt.timestamp}")
  					end
  				end
        end
  		end
    end
	end
end
