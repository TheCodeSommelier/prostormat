# frozen_string_literal: true

module ApplicationHelper
  RECAPTCHA_SITE_KEY = ENV.fetch('RECAPTCHA_SITE_KEY')

  def include_recaptcha_js
    raw %(
      <!-- Google recaptcha start -->
      <script src="https://www.google.com/recaptcha/api.js?render=#{RECAPTCHA_SITE_KEY}" async defer></script>
      <!-- Google recaptcha end -->
    )
  end

  def recaptcha_execute(action)
    id = "recaptcha_token_#{SecureRandom.hex(10)}"

    raw %(
      <!-- Google recaptcha token start -->
      <input name="recaptcha_token" type="hidden" id="#{id}"/>
      <script>
      grecaptcha.ready(function() {
        grecaptcha.execute('#{RECAPTCHA_SITE_KEY}', {action: '#{action}'}).then(function(token) {
          document.getElementById("#{id}").value = token;
          });
        });
      </script>
      <!-- Google recaptcha token end -->
    )
  end
end
