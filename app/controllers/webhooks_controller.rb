class WebhooksController < ApplicationController
  protect_from_forgery except: :stripe

  def stripe
    event = nil

    begin
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      payload = request.body.read
      event = Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_WEBHOOK_ENDPOINT_SECRET'])
    rescue JSON::ParserError => e
      # Invalid payload
      render json: { status: 400, error: e.message } and return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: { status: 400, error:  e.message } and return
    end

    case event['type']
    when 'checkout.session.completed'
      order_id = event.data.object.client_reference_id
      order = Order.find_by(id: order_id, status: :pending)
      customer = order&.user

      if order
        order.fulfilled!
        customer.cart.empty!
        SendOrderConfirmationJob.perform_later(order.id)
      end

    when 'customer.subscription.created'
      stripe_subscription = event.data.object
      seller = User.find_by(stripe_customer_id: stripe_subscription.customer)

      subscription = seller.subscriptions.create(
        stripe_subscription_id: stripe_subscription.id,
        status: stripe_subscription.status,
        amount: stripe_subscription.items.data[0].price.unit_amount / 100.0,
        current_period_start: Time.at(stripe_subscription.current_period_start),
        current_period_end: Time.at(stripe_subscription.current_period_end)
      )
    when 'customer.subscription.updated'
      stripe_subscription = event.data.object
      seller = User.find_by(stripe_customer_id: stripe_subscription.customer)

      subscription = seller.subscriptions.find_by(
        stripe_subscription_id: stripe_subscription.id
      )
      subscription.update(
        status: stripe_subscription.status,
        amount: stripe_subscription.items.data[0].price.unit_amount / 100.0,
        current_period_start: Time.at(stripe_subscription.current_period_start),
        current_period_end: Time.at(stripe_subscription.current_period_end)
      )

    when 'customer.subscription.deleted'
      stripe_subscription = event.data.object
      seller = User.find_by(stripe_customer_id: stripe_subscription.customer)

      subscription = seller.subscriptions.find_by(
        stripe_subscription_id: stripe_subscription.id
      )

      subscription.update(
        status: stripe_subscription.status,
        canceled_at: stripe_subscription.canceled_at
      )
    end

    render json: { status: 200 }
  end
end














