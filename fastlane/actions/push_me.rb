module Fastlane
  module Actions
    class PushMeAction < Action
      def self.description
        "Notify via PushMe (https://itunes.apple.com/us/app/push-me-stay-in-the-loop/id1208277751)"
      end

      def self.run(params)
        require 'uri'
        require "net/http"
        uri = URI('https://pushmeapi.jagcesar.se')
        res = Net::HTTP.post_form(
          uri,
          'title' => params[:title],
          'token' => params[:token],
          'url' => params[:url]
        )
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :token,
                                       env_name: "PUSH_ME_TOKEN",
                                       is_string: true,
                                       description: "The PushMe token to send the push to",
                                       optional: false),
           FastlaneCore::ConfigItem.new(key: :title,
                                        is_string: true,
                                        description: "The PushMe notification title to send",
                                        optional: false),
            FastlaneCore::ConfigItem.new(key: :url,
                                         is_string: true,
                                         description: "The URL to add to the PushMe message",
                                         optional: true)
                                    ]
      end

      def self.authors
        ["natanrolnik"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
