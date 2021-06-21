json.extract! tweet, :id, :author, :content, :created_at, :url, :title
json.url tweet_url(tweet, format: :json)
