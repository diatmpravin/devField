class MwsOrderItemsController < ApplicationController
    
  # GET /mws_order_items
  # GET /mws_order_items.json
  def index
    @mws_order_items = MwsOrderItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mws_order_items }
    end
  end

  # GET /mws_order_items/1
  # GET /mws_order_items/1.json
  def show
    @mws_order_item = MwsOrderItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mws_order_item }
    end
  end

  # GET /mws_order_items/new
  # GET /mws_order_items/new.json
  def new
    @mws_order_item = MwsOrderItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mws_order_item }
    end
  end

  # GET /mws_order_items/1/edit
  def edit
    @mws_order_item = MwsOrderItem.find(params[:id])
  end

  # POST /mws_order_items
  # POST /mws_order_items.json
  def create
    @mws_order_item = MwsOrderItem.new(params[:mws_order_item])

    respond_to do |format|
      if @mws_order_item.save
        format.html { redirect_to @mws_order_item, notice: 'Mws order item was successfully created.' }
        format.json { render json: @mws_order_item, status: :created, location: @mws_order_item }
      else
        format.html { render action: "new" }
        format.json { render json: @mws_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mws_order_items/1
  # PUT /mws_order_items/1.json
  def update
    @mws_order_item = MwsOrderItem.find(params[:id])

    respond_to do |format|
      if @mws_order_item.update_attributes(params[:mws_order_item])
        format.html { redirect_to @mws_order_item, notice: 'Mws order item was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @mws_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mws_order_items/1
  # DELETE /mws_order_items/1.json
  def destroy
    @mws_order_item = MwsOrderItem.find(params[:id])
    @mws_order_item.destroy

    respond_to do |format|
      format.html { redirect_to mws_order_items_url }
      format.json { head :ok }
    end
  end
end
