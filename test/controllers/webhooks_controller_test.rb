require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @product = products(:one)
    @order = orders(:pending_order)
    @user.cart.empty!
    @user.cart.add(@product)
  end

  test "processes successful Stripe checkout session webhook" do

    payload = {
      type: 'checkout.session.completed',
      data: {
        object: {
          client_reference_id: @order.id,
          customer_email: @user.email
        }
      }
    }.to_json

    event_data = OpenStruct.new(
      type: 'checkout.session.completed',
      data: OpenStruct.new(
        object: OpenStruct.new(
          client_reference_id: @order.id,
          customer_email: @user.email
        )
      )
    )

    Stripe::Webhook.expects(:construct_event)
      .with(payload, 'fake_signature', 
        ENV['STRIPE_WEBHOOK_ENDPOINT_SECRET'])
      .returns(event_data)

    ActiveJob::Base.queue_adapter = :test

    assert_enqueued_with(job: SendOrderConfirmationJob,
      args: [@order.id]) do
      post webhooks_stripe_path,
        params: payload,
        headers: {
         'CONTENT_TYPE' => 'application/json',
         'HTTP_STRIPE_SIGNATURE' => 'fake_signature' 
        }
    end

    assert_response :success

    @order.reload
    assert_equal "fulfilled", @order.status

    assert @user.cart.reload.is_empty?

  end

  test "handles invalid signature" do
    Stripe::Webhook.expects(:construct_event)
      .raises(Stripe::SignatureVerificationError.new('Invalid signature', 'sig_header'))

    post webhooks_stripe_path,
         params: { type: 'checkout.session.completed' }.to_json,
         headers: { 
           'CONTENT_TYPE' => 'application/json',
           'HTTP_STRIPE_SIGNATURE' => 'invalid_signature' 
         }

    assert_response :success  # Still returns 200 but with error message
    assert_equal({ "status" => 400, "error" => "Invalid signature" }, JSON.parse(response.body))
  end

  test "handles invalid JSON payload" do
    post webhooks_stripe_path,
         params: "invalid json{",
         headers: { 
           'CONTENT_TYPE' => 'application/json',
           'HTTP_STRIPE_SIGNATURE' => 'fake_signature' 
         }

    assert_response :success  # Still returns 200 but with error message
    assert_equal JSON.parse(response.body)["error"], "Unable to extract timestamp and signatures from header"
  end


end































