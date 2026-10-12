# Keep the admin session inaccessible to JavaScript and limit cross-site cookie use.
# HTTPS-only cookies are enabled in production; local HTTP development remains usable.
Rails.application.config.session_store :cookie_store,
  key: "_dead_programmer_session",
  httponly: true,
  same_site: :lax,
  secure: Rails.env.production?
