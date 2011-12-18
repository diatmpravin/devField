class MwsOrdersController < ApplicationController

  # GET /mws_orders
  # GET /mws_orders.json
  def index  
    @mws_orders = MwsOrder.order('purchase_date DESC').page(params[:page]).per(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mws_orders }
    end
  end

  # GET /mws_orders/1
  # GET /mws_orders/1.json
  def show
    @mws_order = MwsOrder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mws_order }
    end
  end

  # PUT /mws_orders/1
  # PUT /mws_orders/1.json
  def update
    @mws_order = MwsOrder.find(params[:id])
    
		response = @mws_order.reprocess_order

    respond_to do |format|
    	format.html { redirect_to @mws_order, notice: "Amazon order reprocessed.  #{response}" }
      format.json { render json: @mws_order }
    end
  end

end
