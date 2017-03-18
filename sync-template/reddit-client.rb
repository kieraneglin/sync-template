require_relative 'imgur-uploader'
require_relative 'template-parser'
require 'redd'

module SyncTemplate
  class RedditClient
    def initialize
      @session = Redd.it(redd_params)
    end

    def monitor_posts(subreddit)
      @session.subreddit(subreddit).post_stream do |post|
        templates = post.selftext.scan(/\{.*?\}/)
        imgur_links = []
        if !already_commented?(post) && templates.any?
          templates.each do |template|
            begin
              imgur_links << upload_screenshot(template)
              puts "New post: #{imgur_links}"
            rescue
              puts 'Error in template creation'
            end
          end
          post.reply message(imgur_links) if imgur_links.any?
        end
      end
    end

    private

    def message(imgur_links)
      formatted_templates = imgur_links.map do |il|
        # Ugly, but it formats comments to have proper links
        "[#{il[:name] || 'Theme'}](#{il[:url]})"
      end

      "Screenshots for each template: #{formatted_templates.join(', ')}"
    end

    def upload_screenshot(template)
      sync = SyncTemplate::TemplateParser.new template
      imgur_url = SyncTemplate::ImgurUploader.upload_template sync.render
      imgur_hash = { name: sync.name, url: imgur_url }
      sync.cleanup
      imgur_hash
    end

    def already_commented?(post)
      commenters = []
      if post.comments.to_ary.any?
        commenters = post.comments.map { |c| c.author.name }
      end
      commenters.include? ENV['REDDIT_USER']
    end

    def redd_params
      {
        user_agent: 'SyncTemplateBot@v1.0.0',
        client_id:  ENV['REDDIT_CLIENT'],
        secret:     ENV['REDDIT_SECRET'],
        username:   ENV['REDDIT_USER'],
        password:   ENV['REDDIT_PASS']
      }
    end
  end
end
