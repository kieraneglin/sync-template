require 'dotenv/load'
require 'net/http'
require 'base64'
require 'json'

module SyncTemplate
  class ImgurUploader
    class << self
      def upload_template(filepath)
        request = Net::HTTP::Post.new('https://api.imgur.com/3/image')
        request.set_form_data(encode_image(filepath))
        request.add_field('Authorization', authorization)
        response = web_client.request(request)

        JSON.parse(response.body)['data']['link']
      end

      private

      def authorization
        "Client-ID #{ENV['IMGUR_CLIENT']}"
      end

      def encode_image(filepath)
        { image: Base64.encode64(open(filepath).to_a.join) }
      end

      def web_client
        imgur_uri = URI.parse('https://api.imgur.com')
        http = Net::HTTP.new(imgur_uri.host, imgur_uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http
      end
    end
  end
end
