class OrderMailer < ApplicationMailer
  def confirmation
    @order = Order.find(params[:order_id])
    @customer = @order.user

    mail(
      to: @customer.email,
      subject: "Order confirmation ##{@order.id}"
    )
  end
end
