require "test_helper"

class StripeControllerTest < ActionDispatch::IntegrationTest
  test "should get new_checkout_session" do
    get stripe_new_checkout_session_url
    assert_response :success
  end

  test "should get webhooks" do
    get stripe_webhooks_url
    assert_response :success
  end
end
