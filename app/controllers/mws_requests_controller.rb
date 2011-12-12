class MwsRequestsController < ApplicationController
  
  around_filter :shopify_session
  
  # GET /mws_requests
  # GET /mws_requests.json
  def index
    #@mws_requests = MwsRequest.where(:request_type => 'ListOrders').order('created_at DESC')
		@mws_requests = MwsRequest.where('mws_request_id is null').order('created_at DESC').limit(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mws_requests }
    end
  end

  # GET /mws_requests/1
  # GET /mws_requests/1.json
  def show
    @mws_request = MwsRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mws_request }
    end
  end

  # GET /mws_requests/new
  # GET /mws_requests/new.json
  def new
    @mws_request = MwsRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mws_request }
    end
  end

  # GET /mws_requests/1/edit
  def edit
    @mws_request = MwsRequest.find(params[:id])
  end

  # POST /mws_requests
  # POST /mws_requests.json
  def create
    @mws_request = MwsRequest.new(params[:mws_request])

    respond_to do |format|
      if @mws_request.save
        format.html { redirect_to @mws_request, notice: 'Mws request was successfully created.' }
        format.json { render json: @mws_request, status: :created, location: @mws_request }
      else
        format.html { render action: "new" }
        format.json { render json: @mws_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mws_requests/1
  # PUT /mws_requests/1.json
  def update
    @mws_request = MwsRequest.find(params[:id])

    respond_to do |format|
      if @mws_request.update_attributes(params[:mws_request])
        format.html { redirect_to @mws_request, notice: 'Mws request was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @mws_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mws_requests/1
  # DELETE /mws_requests/1.json
  def destroy
    @mws_request = MwsRequest.find(params[:id])
    @mws_request.destroy

    respond_to do |format|
      format.html { redirect_to mws_requests_url }
      format.json { head :ok }
    end
  end
end
