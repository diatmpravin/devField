class MwsOrdersController < ApplicationController

	#around_filter :shopify_session
	
  # GET /mws_orders
  # GET /mws_orders.json
  def index
    @mws_orders = MwsOrder.all

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

  # GET /mws_orders/new
  # GET /mws_orders/new.json
  def new
    @mws_order = MwsOrder.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mws_order }
    end
  end

  # GET /mws_orders/1/edit
  def edit
    @mws_order = MwsOrder.find(params[:id])
  end

  # POST /mws_orders
  # POST /mws_orders.json
  def create
    @mws_order = MwsOrder.new(params[:mws_order])

    respond_to do |format|
      if @mws_order.save
        format.html { redirect_to @mws_order, notice: 'Mws order was successfully created.' }
        format.json { render json: @mws_order, status: :created, location: @mws_order }
      else
        format.html { render action: "new" }
        format.json { render json: @mws_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mws_orders/1
  # PUT /mws_orders/1.json
  def update
    @mws_order = MwsOrder.find(params[:id])

    respond_to do |format|
      if @mws_order.update_attributes(params[:mws_order])
        format.html { redirect_to @mws_order, notice: 'Mws order was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @mws_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mws_orders/1
  # DELETE /mws_orders/1.json
  def destroy
    @mws_order = MwsOrder.find(params[:id])
    @mws_order.destroy

    respond_to do |format|
      format.html { redirect_to mws_orders_url }
      format.json { head :ok }
    end
  end
end
