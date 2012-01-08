class ProductsStoresController < ApplicationController

  # POST /products_stores
  # POST /products_stores.json
  def create
    @ps = ProductsStore.new(params[:products_store])

    respond_to do |format|
      if @ps.save
        format.html { redirect_to @ps.product, notice: 'Product was successfully added to store.' }
        format.json { render json: @ps.product, status: :created, location: @ps.product }
      else
        format.html { redirect_to @ps.product, notice: "Product could not be added to store: #{@ps.errors}." }
        format.json { render json: @ps.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @ps = ProductsStore.find(params[:id])
    @ps.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully removed from store.'  }
      format.json { head :ok }
    end
  end

end
