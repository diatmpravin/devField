class SkuMappingsController < ApplicationController
  # GET /sku_mappings
  # GET /sku_mappings.json
  def index
    @sku_mappings = SkuMapping.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sku_mappings }
    end
  end

  # GET /sku_mappings/1
  # GET /sku_mappings/1.json
  def show
    @sku_mapping = SkuMapping.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sku_mapping }
    end
  end

  # GET /sku_mappings/new
  # GET /sku_mappings/new.json
  def new
    @sku_mapping = SkuMapping.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sku_mapping }
    end
  end

  # GET /sku_mappings/1/edit
  def edit
    @sku_mapping = SkuMapping.find(params[:id])
  end

  # POST /sku_mappings
  # POST /sku_mappings.json
  def create
    @sku_mapping = SkuMapping.new(params[:sku_mapping])

    respond_to do |format|
      if @sku_mapping.save
        format.html { redirect_to @sku_mapping, notice: 'Sku mapping was successfully created.' }
        format.json { render json: @sku_mapping, status: :created, location: @sku_mapping }
      else
        format.html { render action: "new" }
        format.json { render json: @sku_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sku_mappings/1
  # PUT /sku_mappings/1.json
  def update
    @sku_mapping = SkuMapping.find(params[:id])

    respond_to do |format|
      if @sku_mapping.update_attributes(params[:sku_mapping])
        format.html { redirect_to @sku_mapping, notice: 'Sku mapping was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @sku_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sku_mappings/1
  # DELETE /sku_mappings/1.json
  def destroy
    @sku_mapping = SkuMapping.find(params[:id])
    @sku_mapping.destroy

    respond_to do |format|
      format.html { redirect_to sku_mappings_url }
      format.json { head :ok }
    end
  end
end
