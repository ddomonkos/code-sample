class TipsService

  TIPS = {
    dashboard_search_field: nil,
    enable_facebook_bot: nil,
    enter_name: 2.days,
    upload_avatar: 30.days
  }

  class << self

    def mark_seen(user, tip)
      raise ArgumentError unless valid?(tip)
      redis.hset("users:#{user.id}:tips", tip, Time.now.utc)
    end

    def get_unseen_tips(user)
      res = []
      seen_tips = redis.hgetall("users:#{user.id}:tips")
      TIPS.each do |tip, remind_period|
        seen_at = seen_tips[tip.to_s]
        res << tip if !seen_at || (remind_period && Time.parse(seen_at) + remind_period < Time.now)
      end
      res
    end

    def valid?(tip)
      TIPS.keys.map(&:to_s).include?(tip.to_s)
    end

    protected

    def redis
      Redis.current
    end

  end
end
