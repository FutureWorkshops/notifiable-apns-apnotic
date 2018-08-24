require 'notifiable'
require 'apnotic'

module Notifiable
  module Apns
    module Apnotic
  		class Async < Notifiable::NotifierBase
        
        notifier_attribute :certificate, :passphrase, :sandbox
        
        attr_reader :certificate, :passphrase
        
        def sandbox?
          @sandbox == "1"
        end
      
  			protected      
  			def enqueue(device, notification)        				
          raise "Certificate missing" if certificate.nil?
          
          connection = Apnotic::Connection.new(cert_path: certificate, cert_pass: passphrase, url: url)
          
          notification = notification(device, notification)
        
          push = connection.prepare_push(notification)
          push.on(:response) do |response|
            response.ok? ? processed(device, 0) : processed(device, response.status)
            
            device.destroy if response.status == '410' || (response.status == '400' && response.body['reason'] == 'BadDeviceToken')
          end

          connection.push_async(push)
          
          # wait for all requests to be completed
          connection.join

          # close the connection
          connection.close
  			end
    

        private 
        def url
          self.sandbox? ? Apnotic::APPLE_DEVELOPMENT_SERVER_URL : Apnotic::APPLE_PRODUCTION_SERVER_URL
        end
        
        attr_accessor :alert, :badge, :sound, :content_available, :category, :custom_payload, :url_args, :mutable_content, :thread_id
        
          
        def notification(device, notification)
          payload = Apnotic::Notification.new(device.device_token)
          payload.alert = {}
          payload.alert[:title] = notification.title if notification.title
          payload.alert[:body] = notification.message if notification.message
          payload.sound = notification.sound || 'default'
          payload.category = notification.category if notification.category
          payload.content_available = notification.content_available if notification.content_available
          payload.badge = notification.badge_count if notification.badge_count          
          payload.custom_payload = notification.send_params
          payload = {device_token: device.token, custom: , alert: {}}
          payload.thread_id = notification.thread_id if notification.thread_id
          payload.mutable_content = notification.mutable_content if notification.mutable_content 
          payload.category = notification.category if notification.category
                   
          #payload[:identifier] = notification.identifier if notification.identifier
          #payload[:expiry] = notification.expiry if notification.expiry
          payload
        end
  		end
    end
	end
end
