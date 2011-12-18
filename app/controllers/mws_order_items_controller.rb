class MwsOrderItemsController < ApplicationController

  # GET /mws_order_items/1
  # GET /mws_order_items/1.json
  def show
    @mws_order_item = MwsOrderItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mws_order_item }
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
  
end
