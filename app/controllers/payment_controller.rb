class PaymentController < ApplicationController
  def index
    if params[:product].nil? || params[:product].blank?
      redirect_to root_path
    else 
      @product = Product.find(params[:product])
      @amount = params[:amount]
      @user = @product.user
    end
  end

  def charge
    product = Product.find(params[:product_id])
  	user = product.user

  	result = user.charge_account(
  		params[:stripeToken],
  		params[:amount]
  	)

  	if result[:response] == 200
      charge = result[:charge]
      email = params[:email]
      SendEmailJob.set(wait: 10.seconds).perform_later(email, charge.id, product)
  		render 'payment/thank_you'
  	else
  		flash[:alert] = result[:error]
  		redirect_to(:back)
  	end
  end
end
