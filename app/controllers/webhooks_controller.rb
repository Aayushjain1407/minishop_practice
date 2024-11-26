class WebhooksController < ApplicationController
  protect_from_forgery except: :webhook

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

    if event['type'] == 'checkout.session.completed'
      order_id = event.data.object.client_reference_id
      order = Order.find_by(id: order_id, status: :pending)
      customer = order&.user

      if order
        order.fulfilled!
        customer.cart.empty!
        OrderMailer.with(order_id: order_id).confirmation.deliver_later
      end
    end

    render json: { status: 200 }
  end
end
