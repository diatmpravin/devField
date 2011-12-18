class OmxRequestsController < ApplicationController

  # GET /omx_requests
  # GET /omx_requests.json
  def index
    @omx_requests = OmxRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @omx_requests }
    end
  end

  # GET /omx_requests/1
  # GET /omx_requests/1.json
  def show
    @omx_request = OmxRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @omx_request }
    end
  end

  # GET /omx_requests/new
  # GET /omx_requests/new.json
  def new
    @omx_request = OmxRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @omx_request }
    end
  end

  # GET /omx_requests/1/edit
  def edit
    @omx_request = OmxRequest.find(params[:id])
  end

  # POST /omx_requests
  # POST /omx_requests.json
  def create
    @omx_request = OmxRequest.new(params[:omx_request])

    respond_to do |format|
      if @omx_request.save
        format.html { redirect_to @omx_request, notice: 'Omx request was successfully created.' }
        format.json { render json: @omx_request, status: :created, location: @omx_request }
      else
        format.html { render action: "new" }
        format.json { render json: @omx_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /omx_requests/1
  # PUT /omx_requests/1.json
  def update
    @omx_request = OmxRequest.find(params[:id])

    respond_to do |format|
      if @omx_request.update_attributes(params[:omx_request])
        format.html { redirect_to @omx_request, notice: 'Omx request was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @omx_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /omx_requests/1
  # DELETE /omx_requests/1.json
  def destroy
    @omx_request = OmxRequest.find(params[:id])
    @omx_request.destroy

    respond_to do |format|
      format.html { redirect_to omx_requests_url }
      format.json { head :ok }
    end
  end
end
