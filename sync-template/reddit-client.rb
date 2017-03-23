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
        templates = post.selftext.scan(/\{.*?\}/m)
        imgur_links = []
        puts 'Reading Post'
        # In this order, since Ruby fast-fails with &&.  So if there are no
        # templates, the reddit API isn't hit.
        if templates.any? && !already_commented?(post)
          puts 'Found New Post With Template'
          templates.each do |template|
            begin
              imgur_links << upload_screenshot(template)
              puts "New post: #{imgur_links}"
            rescue Exception => e
              # I know it's bad days to rescue from generic error
              # But the result is the same, regardless of the error and the user
              # shouldn't be informed.  So we're doing this
              puts "Error in template creation: #{e}"
            end
          end
          imgur_links.reject! { |a| a[:url] === nil }
          post.reply message(imgur_links) if imgur_links.any?
          sleep 10
        end
      end
    end

    private

    def message(imgur_links)
      formatted_templates = imgur_links.map do |il|
        # Ugly, but it formats comments to have proper links
        # Format: [name](url)
        puts il
        "[#{il[:name] || 'Theme'}](#{il[:url]})" if il[:url]
      end

      "Screenshots for each template: #{formatted_templates.join(', ')} ^^I'm ^^a ^^bot"
    end

    def upload_screenshot(template)
      sync = SyncTemplate::TemplateParser.new template
      imgur_url = SyncTemplate::ImgurUploader.upload_template sync.render
      sync.cleanup
      imgur_hash = { name: sync.name, url: imgur_url }
    end

    def already_commented?(post)
      commenters = []
      # I could probably one-line the rest of this, but clarity > cleverness
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
