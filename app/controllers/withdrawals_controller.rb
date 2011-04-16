class WithdrawalsController < ApplicationController
  before_filter :require_card
  
  def create
    begin
      @transact=current_card.withdraw(params[:amount])
      if @transact["status"]=="ok"
        flash[:notice] = "You successfully withdrew #{@transact['amount']} #{current_card.asset}"
      else
        flash[:notice] = "error: #{@transact['description']}"
      end
    rescue
      flash[:error]="Something went wrong"
      logger.info $!.to_s
    end
    redirect_to card_path
  end
end
