##########################################################
# Until basic classes are finished, this is for testing. #
# This will be the main loop that interacts with reddit. #
##########################################################

require_relative 'sync-template/template-parser'
require_relative 'sync-template/imgur-uploader'

# content = '{ "name": "Peachy",
#   "primary_color": "#b95289",
#   "accent_color": "#FFFFFF",
#   "highlight_color": "#59c99d",
#   "primary_text_color": "#697c8f",
#   "secondary_text_color": "#8d8d8d",
#   "window_color": "#e4e4e4",
#   "content_color": "#ffffff",
#   "auto_subreddit_themes": false }'
#
# s = SyncTemplate::TemplateParser.new content
# puts s.render.path
#

# puts SyncTemplate::ImgurUploader.upload_template "/Users/Kieran/Documents/Programming/redditsync/images/4fb6ca2836f406c7d6bd0eb316.jpg"

require 'redd'

session = Redd.it(
  user_agent: 'SyncTemplateBot',
  client_id:  ENV["REDDIT_CLIENT"],
  secret:     ENV["REDDIT_SECRET"],
  username:   ENV["REDDIT_USER"],
  password:   ENV["REDDIT_PASS"]
)

def message(imgur_links)
  formatted_templates = imgur_links.map do |il|
    # Ugly, but it formats comments to have proper links
    "[#{il[:name] || 'Theme'}](#{il[:url]})"
  end

  "Screenshots for each template: #{formatted_templates.join(", ")}"
end

session.subreddit('SyncTemplateTest').post_stream do |post|
  templates = post.selftext.scan(/\{.*?\}/)
  commenters = []

  if post.comments.to_ary.any?
    commenters = post.comments.map { |c| c.author.name }
  end

  unless commenters.include? ENV["REDDIT_USER"]
    imgur_links = []
    if templates.any?
      templates.each do |template|
        sync = SyncTemplate::TemplateParser.new template
        imgur_url = SyncTemplate::ImgurUploader.upload_template sync.render
        imgur_hash = { name: sync.name, url: imgur_url }
        imgur_links << imgur_hash
      end
      puts imgur_links
      #
      # puts message imgur_links
      post.reply message(imgur_links)
    end
  end
end
