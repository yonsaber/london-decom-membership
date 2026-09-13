class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      remote = env['HTTP_X_FORWARDED_FOR'] ? env['HTTP_X_FORWARDED_FOR'].split(',')[0] : nil
      @remote_ip ||= (remote || ip).to_s
    end
  end

  # Always allow requests from localhost (blocklist & throttles are skipped)
  Rack::Attack.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blocklisting and
  # safelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.remote_ip}"
  Rack::Attack.throttle('req/ip', limit: 50, period: 2.minutes, &:remote_ip)

  Rack::Attack.blocklist_ip('4.204.200.13')
  Rack::Attack.blocklist_ip('4.223.73.90')
  Rack::Attack.blocklist_ip('4.204.224.164')
  Rack::Attack.blocklist_ip('4.232.147.36')
  Rack::Attack.blocklist_ip('13.79.87.25')
  Rack::Attack.blocklist_ip('20.42.209.0')
  Rack::Attack.blocklist_ip('20.42.209.0')
  Rack::Attack.blocklist_ip('20.48.251.3')
  Rack::Attack.blocklist_ip('20.63.81.20')
  Rack::Attack.blocklist_ip('20.215.185.25')
  Rack::Attack.blocklist_ip('20.215.211.30')
  Rack::Attack.blocklist_ip('20.218.119.12')
  Rack::Attack.blocklist_ip('20.220.10.235')
  Rack::Attack.blocklist_ip('20.251.112.224')
  Rack::Attack.blocklist_ip('72.146.20.230')
  Rack::Attack.blocklist_ip('104.28.222.16')
  Rack::Attack.blocklist_ip('104.248.45.83')
  Rack::Attack.blocklist_ip('109.107.189.44')
  Rack::Attack.blocklist_ip('158.23.18.78')
  Rack::Attack.blocklist_ip('185.177.72.58')

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.remote_ip}"
  Rack::Attack.throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    req.remote_ip if req.path == '/users/sign_in' && req.post?
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{normalized_email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  Rack::Attack.throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      # Normalize the email, using the same logic as your authentication process, to
      # protect against rate limit bypasses. Return the normalized email if present, nil otherwise.
      req.params['email'].to_s.downcase.gsub(/\s+/, '').presence
    end
  end

  # Block suspicious requests for '/etc/password' or wordpress specific paths.
  # After 3 blocked requests in 10 minutes, block all requests from that IP for 10 minutes.
  Rack::Attack.blocklist('fail2ban pentesters') do |req|
    # `filter` returns truthy value if request fails, or if it's from a previously banned IP
    # so the request is blocked
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 10.minutes) do
      # The count for the IP is incremented if the return value is truthy
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
        req.path.include?('/etc/passwd') ||
        req.path.include?('wp-admin') ||
        req.path.include?('wp-login')
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_responder = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end
end
