# frozen_string_literal: true

return unless File.exist?(Rails.root.join('config/click_house.yml'))

raw_config = Rails.application.config_for(:click_house)

return if raw_config.blank?

ClickHouse::Client.configure do |config|
  raw_config.each do |database_identifier, db_config|
    config.register_database(database_identifier,
      database: db_config[:database],
      url: db_config[:url],
      username: db_config[:username],
      password: db_config[:password],
      variables: db_config[:variables] || {}
    )
  end

  config.json_parser = Gitlab::Json
  config.http_post_proc = ->(url, headers, body) do
    options = {
      headers: headers,
      body: ActiveSupport::Gzip.compress(body),
      allow_local_requests: Rails.env.development? || Rails.env.test?
    }

    response = Gitlab::HTTP.post(url, options)
    ClickHouse::Client::Response.new(response.body, response.code, response.headers)
  end
end
