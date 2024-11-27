class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: %i[ show destroy ]

  # GET /subscriptions/1 or /subscriptions/1.json
  def show
    @stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_subscription_id)
    @next_payment = Time.at(@stripe_subscription.current_period_end)
    @last_payment = Time.at(@stripe_subscription.current_period_start)
    @invoices = Stripe::Invoice.list(subscription: @subscription.stripe_subscription_id)
  rescue Stripe::InvalidRequestError
    redirect_to root_path, alert: "Subscription data unavailable"
  end

  # GET /subscriptions/new
  def new
  end

  # POST /subscriptions or /subscriptions.json
  def create
    current_user.setup_stripe_customer
    session = Stripe::Checkout::Session.create(
      customer: current_user.stripe_customer_id,
      payment_method_types: ['card'],
      line_items: [{
        price: 'price_0QPPwwoDMzScYFKjxNJnctCB',
        quantity: 1
      }],
      mode: 'subscription',
      success_url: root_url,
      cancel_url: new_subscription_url
    )
    redirect_to session.url, allow_other_host: true
  end

  # DELETE /subscriptions/1 or /subscriptions/1.json
  def destroy
    Stripe::Subscription.update(
      @subscription.stripe_subscription_id,
      { cancel_at_period_end: true }
    )
    @subscription.update(canceled_at: Time.current)
    redirect_to @subscription, notice: 'Your Pro subscription will be cancelled at the end of the current billing period.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subscription_params
      params.fetch(:subscription, {})
    end
end
